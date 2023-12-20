class City:
    def __init__(self, name):
        self.name = name

    def AddCityTable(self, cur, conn):
        query = f"INSERT INTO city (name) VALUES ('{self.name}');"
        cur.execute(query)
        conn.commit()

    @staticmethod
    def QueryCityTable(self, cur, conn):  #Bu fonksiyon şehir tablosundan şehir adına göre şehir id'sini döndürür.
                                          # Eğer şehir yoksa tabloya ekler
        query = f"SELECT * FROM city WHERE name = '{self.name}';"
        cur.execute(query)
        rows = cur.fetchall()
        if len(rows) == 0:
            self.AddCityTable(cur, conn)
            return self.QueryCityTable(self, cur, conn)
        else:
            return rows[0][0]




