class Person:
    def __init__(self, name, surname, tckn, phone, address, role):
        self.name = name
        self.surname = surname
        self.tckn = tckn
        self.phone = phone
        self.address = address
        self.role = role


    def AddPersonTable(self, cur, conn):
        query = f"INSERT INTO person (name, surname, tckn, phone, address, role) VALUES ('{self.name}', '{self.surname}', {self.tckn}, {self.phone}, '{self.address}', '{self.role}');"
        cur.execute(query)
        conn.commit()


    @staticmethod
    def QueryPersonTable(self, cur, conn):
        query = f"SELECT * FROM person WHERE tckn = {self.tckn} AND role = {self.role};"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddPersonTable(cur, conn)
            return self.QueryPersonTable(self, cur, conn)
        else:
            return rows[0][0]


    @staticmethod
    def GetId(tckn, cur, role):
        query = f"SELECT * FROM person WHERE tckn = {tckn} AND role = {role};"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nKullanıcı bulunamadı.")
        else:
            return rows[0][0]