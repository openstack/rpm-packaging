from monasca_api.api import server

application = server.get_wsgi_app(config_base_path='/etc/monasca')
