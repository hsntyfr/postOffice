from prettytable import PrettyTable

import customer


class Pack:
    def __init__(self, address, customer, warehouseStaff, courier, mass, cost, paymentType, status, receipt, score = 0):
        self.address = address
        self.customer = customer
        self.warehouseStaff = warehouseStaff
        self.courier = courier
        self.mass = mass
        self.cost = cost
        self.paymentType = paymentType
        self.status = status
        self.receipt = receipt
        self.score = score

    def AddPackTable(self, cur, conn):
        query = f"INSERT INTO pack (address, customer, \"warehouseStaff\", courier, mass, cost, \"paymentType\", status, receipt, score) VALUES ({self.address}, {self.customer}, {self.warehouseStaff}, {self.courier}, {self.mass}, {self.cost}, '{self.paymentType}', '{self.status}', {self.receipt}, {self.score});"
        cur.execute(query)
        conn.commit()


    @staticmethod
    def QueryPackTable(tckn, cur, conn):
        id = customer.Customer.IsCustomer(tckn, cur)
        query = f"SELECT * FROM pack WHERE customer = {id};"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nKargo bulunamadı. Kayıt açınız.")
        else:
            return rows[0][0]

    @staticmethod
    def ListPacksCourier(id, cur):
        # query = f"SELECT id, address, customer, cost, \"paymentType\" FROM pack WHERE courier = {id} AND status = 3;"
        query = f"""SELECT pack.id, person.name, person.surname, city.name AS il, district.name AS ilce, area.name AS mahalle, address.detail AS detay, \"paymentType\".name AS odeme, pack.cost AS ucret FROM pack 
JOIN person ON pack.customer = person.id
JOIN address ON pack.address = address.id
JOIN city ON address.city = city.id
JOIN district ON address.district = district.id
JOIN area ON address.area = area.id
JOIN \"paymentType\" ON pack.\"paymentType\" = \"paymentType\".id 
WHERE courier = {id} AND status = 3 AND person.role = 3;"""
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nKuryenin teslim edeceği kargo bulunmamaktadır.")
        else:
            heads = ["id", "isim", "soyisim", "sehir", "ilce", "mahalle", "detay", "odeme", "ucret"]
            table = PrettyTable()
            table.field_names = heads
            for row in rows:
                table.add_row(row)
            print(table)

    @staticmethod
    def UpdatePackStatus(id, cur, conn, status):
        query = f"UPDATE pack SET status = {status} WHERE id = {id};"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def AcceptPack(id, cur, conn):
        query = f"UPDATE pack SET status = 4 WHERE id = {id};"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def ListPacksCustomer(tckn, cur):
        id = customer.Customer.IsCustomer(tckn, cur)
        print(id)
        query = f"SELECT id, address, customer, cost, \"paymentType\" FROM pack WHERE customer = {id} AND status = 4;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nMüşterinin teslim alacağı kargo bulunmamaktadır.")
        else:
            heads = ["id", "address", "customer", "cost", "paymentType"]
            table = PrettyTable()
            table.field_names = heads
            for row in rows:
                table.add_row(row)
            print(table)

    @staticmethod
    def DeletePack(id, cur, conn):
        query = f"DELETE FROM pack WHERE id = {id};"
        try:
            cur.execute(query)
            conn.commit()
        except:
            print("Kargo silinemedi.")