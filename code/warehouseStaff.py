import person

class WarehouseStaff (person.Person):
    def __init__(self, name, surname, tckn, phone, address, score, enteredPack, warehouse):
        super().__init__(name, surname, tckn, phone, address, 4)
        self.warehouse = warehouse
        self.score = score
        self.enteredPack = enteredPack

    def AddWarehouseStaffTable(self, cur, conn):
        super().AddPersonTable(cur, conn)
        query = f"SELECT last_value FROM person_id_seq";
        cur.execute(query)
        rows = cur.fetchall()
        id = rows[0][0]
        query = f"INSERT INTO \"warehouseStaff\" (id, score, \"enteredPack\", warehouse) VALUES ({id}, {self.score}, {self.enteredPack}, {self.warehouse});"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def QueryWarehouseStaffTable(self, cur, conn):
        query = f"SELECT * FROM person WHERE tckn = {self.tckn} AND role = 4;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddWarehouseStaffTable(cur, conn)
            return self.QueryWarehouseStaffTable(self, cur, conn)
        else:
            return rows[0][0]

    @staticmethod
    def IsWarehouseStaff(tckn, cur):
        query = f"SELECT * FROM person WHERE tckn = {tckn} AND role = 4;"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            print("\nDepo görevlisi değilsiniz.")
        else:
            return rows[0][0]