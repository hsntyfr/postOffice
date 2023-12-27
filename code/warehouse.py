class Warehouse:
    def __init__(self, id, address):
        self.id = id
        self.address = address


    def AddWarehouseTable(self, cur, conn):
        query = f"INSERT INTO warehouse (id, address) VALUES ({self.id}, {self.address});"
        cur.execute(query)
        conn.commit()


    @staticmethod
    def QueryWarehouseTable(self, cur, conn):
        query = f"SELECT * FROM warehouse WHERE id = {self.id};"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddWarehouseTable(cur, conn)
            return self.QueryWarehouseTable(self, cur, conn)
        else:
            return rows[0][0]

