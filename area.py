import district as d
import city as city

class Area:
    def __init__(self, name, district, city):
        self.name = name
        self.district = district
        self.city = city

    @staticmethod
    def QueryDistrictTable(self, cur, conn):
        c = city.City(self.city)
        cityID = c.QueryCityTable(c, cur, conn)
        query = f"SELECT * FROM district WHERE name = '{self.name}' AND city = {cityID};"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddDistrictTable(cur, conn, cityID)
            return self.QueryDistrictTable(self, cur, conn)
        else:
            return rows[0][0]
