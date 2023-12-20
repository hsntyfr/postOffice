import person

class Customer (person.Person):
    def __init__(self, name, surname, tckn, phone, address, priority):
        super().__init__(name, surname, tckn, phone, address, 3)
        self.priority = priority


    def AddCustomerTable(self, cur, conn):
        super().AddPersonTable(cur, conn)
        query = f"SELECT last_value FROM person_id_seq";
        cur.execute(query)
        rows = cur.fetchall()
        id = rows[0][0]
        query = f"INSERT INTO customer (id, priority) VALUES ({id}, {self.priority});"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def QueryCustomerTable(self, cur, conn):
        query = f"SELECT * FROM person WHERE tckn = {self.tckn} AND role = 3;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddCustomerTable(cur, conn)
            return self.QueryCustomerTable(self, cur, conn)
        else:
            return rows[0][0]

    @staticmethod
    def IsCustomer(tckn, cur):
        query = f"SELECT * FROM person WHERE tckn = {tckn} AND role = 3;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nMüşteri bulunamadı. Kayıt açınız.")
        else:
            return rows[0][0]