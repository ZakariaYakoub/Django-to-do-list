from django.urls import path
from .views import PendingList,TaskDetail,CreateTask,EditTask,DeleteTask,Login,RegisterPage
from django.contrib.auth.views import LogoutView


urlpatterns = [path('',PendingList.as_view(),name = 'pendings'),
               path('login/',Login.as_view(),name = 'login'),
               path('logout/',LogoutView.as_view(next_page='login'),name = 'logout'),
               path('task/<int:pk>',TaskDetail.as_view(),name = 'task'),
               path('create-task/',CreateTask.as_view(),name = 'create-task'),
               path('edit-task/<int:pk>',EditTask.as_view(),name = 'edit-task'),
               path('delete-task/<int:pk>',DeleteTask.as_view(),name = 'delete-task'),
               path('signup/',RegisterPage.as_view(),name = 'signup')

               ]
