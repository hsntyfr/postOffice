from prettytable import PrettyTable
class PaymentType:
    @staticmethod
    def ListPaymentType(cur):
        query = f"SELECT * FROM \"paymentType\";"
        cur.execute(query)
        rows = cur.fetchall()
        heads = ["id", "paymentType"]
        table = PrettyTable()
        table.field_names = heads
        for row in rows:
            table.add_row(row)
        print(table)