apps = [
    {"app": "App A", "category": "Game", "installs": 10000, "price": 2.99},
    {"app": "App B", "category": "Productivity", "installs": 5000, "price": 4.99},
    {"app": "App C", "category": "Game", "installs": 20000, "price": 1.99},
]


for app in apps:
    app['cost'] = app['installs'] * app['price']


apps_sorted = sorted(apps, key=lambda x: x['cost'], reverse=True)

# Step 3: Print the sorted list
print("Apps sorted by cost:")
for app in apps_sorted:
    print(f"{app['app']} ({app['category']}): ${app['cost']:.2f}")