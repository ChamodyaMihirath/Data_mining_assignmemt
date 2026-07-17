from pathlib import Path
import pandas as pd
import gc

from sqlalchemy import create_engine, text



class RetailETL:

    def __init__(self):

        # MySQL Connection

        self.engine = create_engine(
            "mysql+mysqlconnector://root:@localhost/retail_dw"
        )


        # Project Path

        project_root = Path(__file__).resolve().parent.parent


        self.file_path = (
            project_root
            / "data"
            / "raw"
            / "online_Retail_II.xlsx"
        )


        self.df = None



    # =====================================================
    # EXTRACT
    # =====================================================

    def extract_data(self):

        print("\nExtracting data...")


        sheet1 = pd.read_excel(
            self.file_path,
            sheet_name=0
        )


        sheet2 = pd.read_excel(
            self.file_path,
            sheet_name=1
        )


        self.df = pd.concat(
            [
                sheet1,
                sheet2
            ],
            ignore_index=True
        )


        print(
            "Rows extracted:",
            len(self.df)
        )



    # =====================================================
    # CLEAN DATA
    # =====================================================

    def clean_data(self):

        print("\nCleaning data...")


        self.df.rename(
            columns={
                "Customer ID": "CustomerID",
                "Invoice": "InvoiceNumber",
                "Price": "UnitPrice"
            },
            inplace=True
        )


        # Remove duplicates

        before = len(self.df)

        self.df.drop_duplicates(
            inplace=True
        )


        print(
            "Duplicates removed:",
            before-len(self.df)
        )



        # Missing values

        self.df["CustomerID"] = (
            self.df["CustomerID"]
            .fillna(-1)
            .astype(int)
        )


        self.df["Description"] = (
            self.df["Description"]
            .fillna("Unknown Product")
        )



        self.df["Country"] = (
            self.df["Country"]
            .fillna("Unknown")
        )



        # Remove cancellations

        before = len(self.df)


        self.df = self.df[
            ~self.df["InvoiceNumber"]
            .astype(str)
            .str.startswith("C")
        ]


        print(
            "Cancelled invoices removed:",
            before-len(self.df)
        )



        # Remove invalid transactions

        before = len(self.df)


        self.df = self.df[
            (self.df["Quantity"] > 0)
            &
            (self.df["UnitPrice"] > 0)
        ]


        print(
            "Invalid rows removed:",
            before-len(self.df)
        )



        # Measure

        self.df["SalesAmount"] = (
            self.df["Quantity"]
            *
            self.df["UnitPrice"]
        )



        print(
            "Rows after cleaning:",
            len(self.df)
        )



    # =====================================================
    # DIM CUSTOMER
    # =====================================================

    def load_customer_dimension(self):

        print("\nLoading DIM_CUSTOMER...")


        customer = (
            self.df[
                [
                    "CustomerID",
                    "Country"
                ]
            ]
            .drop_duplicates(
                subset=["CustomerID"]
            )
        )


        customer.to_sql(
            "dim_customer",
            self.engine,
            if_exists="append",
            index=False,
            method="multi"
        )


        print(
            "Customers loaded:",
            len(customer)
        )



    # =====================================================
    # DIM PRODUCT
    # =====================================================

    def load_product_dimension(self):

        print("\nLoading DIM_PRODUCT...")


        product = (
            self.df[
                [
                    "StockCode",
                    "Description"
                ]
            ]
            .drop_duplicates(
                subset=["StockCode"]
            )
        )


        product.to_sql(
            "dim_product",
            self.engine,
            if_exists="append",
            index=False,
            method="multi"
        )



        # Unknown Product

        unknown_product = pd.DataFrame(
            {
                "StockCode":[
                    "UNKNOWN"
                ],

                "Description":[
                    "Unknown Product"
                ]
            }
        )


        unknown_product.to_sql(
            "dim_product",
            self.engine,
            if_exists="append",
            index=False
        )


        print(
            "Products loaded:",
            len(product)+1
        )



    # =====================================================
    # DIM TIME
    # =====================================================

    def load_time_dimension(self):

        print("\nLoading DIM_TIME...")


        dates = (
            self.df[
                [
                    "InvoiceDate"
                ]
            ]
            .drop_duplicates()
        )


        time = pd.DataFrame()


        time["FullDate"] = (
            dates["InvoiceDate"]
            .dt.date
        )


        time["Day"] = (
            dates["InvoiceDate"]
            .dt.day
        )


        time["Month"] = (
            dates["InvoiceDate"]
            .dt.month
        )


        time["MonthName"] = (
            dates["InvoiceDate"]
            .dt.month_name()
        )


        time["Quarter"] = (
            dates["InvoiceDate"]
            .dt.quarter
        )


        time["Year"] = (
            dates["InvoiceDate"]
            .dt.year
        )


        time["WeekNumber"] = (
            dates["InvoiceDate"]
            .dt.isocalendar()
            .week
            .astype(int)
        )


        time["DayOfWeek"] = (
            dates["InvoiceDate"]
            .dt.day_name()
        )


        time["IsWeekend"] = (
            dates["InvoiceDate"]
            .dt.dayofweek >= 5
        )


        time = time.drop_duplicates(
            subset=["FullDate"]
        )


        time.to_sql(
            "dim_time",
            self.engine,
            if_exists="append",
            index=False,
            method="multi"
        )


        print(
            "Time loaded:",
            len(time)
        )



    # =====================================================
    # FACT SALES
    # =====================================================

    def load_fact_sales(self):

        print("\nLoading FACT_SALES...")


        customer_map = pd.read_sql(
            """
            SELECT
            CustomerKey,
            CustomerID
            FROM dim_customer
            """,
            self.engine
        )



        product_map = pd.read_sql(
            """
            SELECT
            ProductKey,
            StockCode
            FROM dim_product
            """,
            self.engine
        )



        time_map = pd.read_sql(
            """
            SELECT
            TimeKey,
            FullDate
            FROM dim_time
            """,
            self.engine
        )



        fact = self.df.copy()



        # Customer lookup

        fact = fact.merge(
            customer_map,
            on="CustomerID",
            how="left"
        )



        # Product lookup

        fact = fact.merge(
            product_map,
            on="StockCode",
            how="left"
        )



        # Replace missing product key

        unknown_product_key = (
            product_map[
                product_map["StockCode"]=="UNKNOWN"
            ]
            ["ProductKey"]
            .iloc[0]
        )


        fact["ProductKey"] = (
            fact["ProductKey"]
            .fillna(
                unknown_product_key
            )
        )



        # Time lookup


        fact["FullDate"] = (
            fact["InvoiceDate"]
            .dt.date
        )


        fact = fact.merge(
            time_map,
            on="FullDate",
            how="left"
        )



        fact_final = fact[
            [
                "CustomerKey",
                "ProductKey",
                "TimeKey",
                "InvoiceNumber",
                "Quantity",
                "UnitPrice",
                "SalesAmount"
            ]
        ]



        print(
            "Fact rows:",
            len(fact_final)
        )



        # Chunk loading

        chunk_size = 5000


        for start in range(
            0,
            len(fact_final),
            chunk_size
        ):

            end = start + chunk_size


            chunk = fact_final.iloc[
                start:end
            ]


            chunk.to_sql(
                "FACT_SALES",
                self.engine,
                if_exists="append",
                index=False,
                method="multi"
            )


            print(
                f"Loaded {start} - {end}"
            )


            del chunk
            gc.collect()



        print(
            "FACT loading completed"
        )



    # =====================================================
    # VALIDATION
    # =====================================================

    def validation(self):

        print("\nValidation")


        tables = [
            "dim_customer",
            "dim_product",
            "dim_time",
            "fact_sales"
        ]


        with self.engine.connect() as conn:


            for table in tables:

                result = conn.execute(
                    text(
                        f"""
                        SELECT COUNT(*)
                        FROM {table}
                        """
                    )
                )


                print(
                    table,
                    ":",
                    result.scalar()
                )



    # =====================================================
    # PIPELINE
    # =====================================================

    def run(self):

        self.extract_data()

        self.clean_data()

        self.load_customer_dimension()

        self.load_product_dimension()

        self.load_time_dimension()

        self.load_fact_sales()

        self.validation()



if __name__ == "__main__":

    etl = RetailETL()

    etl.run()