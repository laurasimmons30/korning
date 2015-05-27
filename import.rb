# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

def exists_by_name?(name, table)
  result = db_connection do |conn|
    conn.exec("SELECT name FROM #{table} WHERE name = '#{name}'") 
  end
  result.ntuples > 0
end

def grab_id_for_name(name, table)
  result = db_connection do |conn|
    conn.exec("SELECT id FROM #{table} WHERE name = '#{name}'")
  end
  # return id
  result.values.first.first
end

def exists_by_invoice_no?(number)
  result = db_connection do |conn|
    conn.exec("SELECT invoice_no FROM sales WHERE invoice_no = '#{number}'")
  end
  result.ntuples > 0
end

sales_data = [] 
CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
  sales_data <<  row.to_hash
end


employees = sales_data.map do |element|
  element[:employee]
end.uniq

@employees = {}
@customers = {}
@products = {}

employees.each do |employee|
  # array of [name, email]
  array = employee.gsub(')','').split(' (')
  #DB STUFF HERE
  unless exists_by_name?(array[0], 'employees')
    db_connection do |conn|
      conn.exec_params("INSERT INTO employees (name, email) Values ($1, $2)", [array[0], array[1]])
    end
  end
  id = grab_id_for_name(array[0],'employees')
  @employees[employee] = id
end

customers = sales_data.map do |element|
  element[:customer_and_account_no]
end.uniq

customers.each do |customer|
  # array of [name,email]
  array = customer.gsub(')','').split(' (')

  unless exists_by_name?(array[0], 'customers')
    db_connection do |conn|
      conn.exec_params("INSERT INTO customers (name, account_no) VALUES ($1, $2)", [array[0], array[1]])
    end
  end
  id = grab_id_for_name(array[0],'customers')
  @customers[customer] = id
end

products = sales_data.map do |element|
  element[:product_name]
end.uniq

products.each do |product|
  unless exists_by_name?(product, 'products')
    db_connection do |conn|
      conn.exec_params("INSERT INTO products (name) VALUES ($1)", [product])
    end
  end
  id = grab_id_for_name(product,'products')
  @products[product] = id
end  

sales_data.each do |sale|
  unless exists_by_invoice_no?(sale[:invoice_no])
    db_connection do |conn|
      conn.exec_params("INSERT INTO sales (sale_date, sale_amount, units_sold, invoice_no, invoice_frequency, product_id, employee_id, customers_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)", [ sale[:sale_date], sale[:sale_amount].gsub('$',''), sale[:units_sold], sale[:invoice_no], sale[:invoice_frequency], @products[sale[:product_name]], @employees[sale[:employee]], @customers[sale[:customer_and_account_no]] ] )
    end
  end
end

