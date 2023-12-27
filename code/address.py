import city
import district
import area
from prettytable import PrettyTable

import person


class Address:
    def __init__(self, city, district, area, detail, person):
        self.city = city
        self.district = district
        self.area = area
        self.detail = detail
        self.person = person



    def AddAddressTable(self, cur, conn, cityId, districtId, areaId, person):
        query = f"INSERT INTO address (city, district, area, detail, person) VALUES ({cityId}, {districtId}, {areaId}, '{self.detail}', {person});"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def QueryAddressTable(self, cur, conn):
        c = city.City(self.city)
        cityId = c.QueryCityTable(c, cur, conn)
        d = district.District(self.district, self.city)
        districtId = d.QueryDistrictTable(d, cur, conn)
        a = area.Area(self.area, self.district, self.city)
        areaId = a.QueryAreaTable(a, cur, conn)
        query = f"SELECT * FROM address WHERE city = {cityId} AND district = {districtId} AND area = {areaId} AND detail = '{self.detail}';"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddAddressTable(cur, conn, cityId, districtId, areaId, self.person)
            return self.QueryAddressTable(self, cur, conn)
        else:
            return rows[0][0]

    @staticmethod
    def GetAddress(tckn, cur, role):
        id = person.Person.GetId(tckn, cur, role)
        query = f'''SELECT a.id, c.name, d.name, ar.name, a.detail
        FROM address a
        INNER JOIN city c ON a.city = c.id
        INNER JOIN district d ON a.district = d.id
        INNER JOIN area ar ON a.area = ar.id
        WHERE a.person = {id};'''
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nAdres bulunamadı.")
        else:
            headers = ["id", "city", "district", "area", "detail"]
            table = PrettyTable()
            table.field_names = headers
            for row in rows:
                table.add_row(row)
            return print(table)

    # @staticmethod
    # def UpdateAddress(cur, conn, id, city1, district1, area1, detail):
    #
    #     query = f"UPDATE address SET city = {cityId}, district = {districtId}, area = {areaId}, detail = '{detail}' WHERE id = {id};"
    #     cur.execute(query)
    #     conn.commit()