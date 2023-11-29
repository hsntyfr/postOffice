import psycopg2
import area as a
import city as c
import district as d



host = "localhost"
databaseName = "postOffice"
port = 5432
password = "123456"
user = "postgres"

try:
    conn = psycopg2.connect(
        host=host,
        dbname=databaseName,
        user=user,
        password=password,
        port=port
    )
    cur = conn.cursor()
except Exception as error:
    print("Hata:", error)


# c = c.City("astanbul")
# print(c.QueryCityTable(c, cur, conn))

# d = d.District("iokyayyy", "Ankara")
# print(d.QueryDistrictTable(d, cur, conn))







conn.close()
cur.close()