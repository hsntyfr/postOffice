from prettytable import PrettyTable

import customer


class Pack:
    def __init__(self, address, customer, warehouseStaff, courier, mass, cost, paymentType, status, receipt):
        self.address = address
        self.customer = customer
        self.warehouseStaff = warehouseStaff
        self.courier = courier
        self.mass = mass
        self.cost = cost
        self.paymentType = paymentType
        self.status = status
        self.receipt = receipt

    def AddPackTable(self, cur, conn):
        query = f"INSERT INTO pack (address, customer, \"warehouseStaff\", courier, mass, cost, \"paymentType\", status, receipt) VALUES ({self.address}, {self.customer}, {self.warehouseStaff}, {self.courier}, {self.mass}, {self.cost}, '{self.paymentType}', '{self.status}', {self.receipt});"
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
        query = f"SELECT id, address, customer, cost, \"paymentType\" FROM pack WHERE courier = {id} AND status = 3;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nKuryenin teslim edeceği kargo bulunmamaktadır.")
        else:
            heads = ["id", "address", "customer", "cost", "paymentType"]
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