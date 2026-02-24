from flask import Flask, render_template
import json

app = Flask(__name__)

# Sample sales data
def get_sales_data():
    return {
        'monthly_sales': [
            {'month': 'Jan', 'revenue': 45000, 'units': 150},
            {'month': 'Feb', 'revenue': 52000, 'units': 175},
            {'month': 'Mar', 'revenue': 48000, 'units': 160},
            {'month': 'Apr', 'revenue': 61000, 'units': 200},
            {'month': 'May', 'revenue': 58000, 'units': 190},
            {'month': 'Jun', 'revenue': 65000, 'units': 215}
        ],
        'top_products': [
            {'name': 'Product A', 'sales': 25000},
            {'name': 'Product B', 'sales': 18000},
            {'name': 'Product C', 'sales': 15000},
            {'name': 'Product D', 'sales': 12000},
            {'name': 'Product E', 'sales': 8000}
        ],
        'total_revenue': 329000,
        'total_units': 1090,
        'avg_order_value': 301.83
    }

@app.route('/')
def dashboard():
    sales_data = get_sales_data()
    return render_template('dashboard.html', data=sales_data)

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
