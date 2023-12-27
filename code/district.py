import city

class District:
    def __init__(self, name, city):
        self.name = name
        self.city = city

    def AddDistrictTable(self, cur, conn, cityId):
        query = f"INSERT INTO district (name, city) VALUES ('{self.name}', {cityId});"
        cur.execute(query)
        conn.commit()

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

