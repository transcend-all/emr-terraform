from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("yarn") \
    .appName("example spark app") \
    .getOrCreate()

df = spark.read.option("header", "true").csv("test_data/aws_ratings_dataset.csv")

df.show()