Setting.create(domain_id: 1, section: 'store', key: 'Authorize.Net Login ID', value: 'xxxxx', value_type: 'string')
Setting.create(domain_id: 1, section: 'store', key: 'Authorize.Net Transaction Key', value: 'xxxxx', value_type: 'string')
Setting.create(domain_id: 1, section: 'store', key: 'PayPal API Username', value: 'xxxxxx', value_type: 'string')
Setting.create(domain_id: 1, section: 'store', key: 'PayPal API Password', value: 'xxxxxx', value_type: 'string')
Setting.create(domain_id: 1, section: 'store', key: 'PayPal Signature', value: 'xxxxxxxxxx', value_type: 'string')

Permission.create(section: 'billing', resource: 'admin', action: 'login')

Permission.create(section: 'billing', resource: 'payment_method', action: 'read')
Permission.create(section: 'billing', resource: 'payment_method', action: 'create')
Permission.create(section: 'billing', resource: 'payment_method', action: 'update')
Permission.create(section: 'billing', resource: 'payment_method', action: 'destroy')

Permission.create(section: 'billing', resource: 'package', action: 'read')
Permission.create(section: 'billing', resource: 'package', action: 'create')
Permission.create(section: 'billing', resource: 'package', action: 'update')
Permission.create(section: 'billing', resource: 'package', action: 'destroy')

Permission.create(section: 'billing', resource: 'user_package', action: 'read')
Permission.create(section: 'billing', resource: 'user_package', action: 'create')
Permission.create(section: 'billing', resource: 'user_package', action: 'update')
Permission.create(section: 'billing', resource: 'user_package', action: 'destroy')

Permission.create(section: 'billing', resource: 'payment', action: 'read')
Permission.create(section: 'billing', resource: 'payment', action: 'create')
Permission.create(section: 'billing', resource: 'payment', action: 'update')
Permission.create(section: 'billing', resource: 'payment', action: 'destroy')