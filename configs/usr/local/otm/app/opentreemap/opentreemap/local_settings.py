EXTRA_UNMANAGED_APPS = ('django_extensions',)

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': 'otm',
        'USER': 'otm',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '5432'
    }
}

BROKER_URL = 'redis://localhost:6379/'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/'
