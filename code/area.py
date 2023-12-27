import district
import city

class Area:
    def __init__(self, name, district, city):
        self.name = name
        self.district = district
        self.city = city


    def AddAreaTable(self, cur, conn, cityId, districtId):
        query = f"INSERT INTO area (city, district, name) VALUES ({cityId}, {districtId}, '{self.name}');"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def QueryAreaTable(self, cur, conn):
        c = city.City(self.city)
        cityId = c.QueryCityTable(c, cur, conn)
        d = district.District(self.district, self.city)
        districtId = d.QueryDistrictTable(d, cur, conn)
        query = f"SELECT * FROM area WHERE name = '{self.name}' AND city = {cityId} AND district = {districtId};"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddAreaTable(cur, conn, cityId, districtId)
            return self.QueryAreaTable(self, cur, conn)
        else:
            return rows[0][0]
