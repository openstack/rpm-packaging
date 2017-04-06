from monasca_log_api import server

application = server.get_wsgi_app(config_base_path='/etc/monasca')

