from prettytable import PrettyTable

class Role:
    @staticmethod
    def ListRole(cur):
        query = f"SELECT * FROM role;"
        cur.execute(query)
        rows = cur.fetchall()
        headers = ["id", "rol"]
        table = PrettyTable()
        table.field_names = headers
        for row in rows:
            table.add_row(row)
        return print(table)