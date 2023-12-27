import person

class Courier (person.Person):
    def __init__(self, name, surname, tckn, phone, address, score, enteredPack):
        super().__init__(name, surname, tckn, phone, address, 2)
        self.score = score
        self.enteredPack = enteredPack


    def AddCourierTable(self, cur, conn):
        super().AddPersonTable(cur, conn)
        query = f"SELECT last_value FROM person_id_seq";
        cur.execute(query)
        rows = cur.fetchall()
        id = rows[0][0]
        query = f"INSERT INTO courier (id, score, \"deliveredPack\") VALUES ({id}, {self.score}, {self.enteredPack});"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def QueryCourierTable(self, cur, conn):
        query = f"SELECT * FROM person WHERE tckn = {self.tckn} AND role = 2;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddCourierTable(cur, conn)
            return self.QueryCourierTable(self, cur, conn)
        else:
            return rows[0][0]


    @staticmethod
    def IsCourier(tckn, cur):
        query = f"SELECT * FROM person WHERE tckn = {tckn} AND role = 2;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nKurye değilsiniz.")
        else:
            return rows[0][0]