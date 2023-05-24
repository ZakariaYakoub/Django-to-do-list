from django.db import models
from django.contrib.auth.models import User


# Create a table task
class Task(models.Model):
    #attribute of the class (the columns of the table)
    user = models.ForeignKey(User,
                             on_delete = models.CASCADE,
                             null = True,
                             blank = False)
    title = models.CharField(max_length=200)
    description = models.TextField(null = True,blank = True)
    complete = models.BooleanField(default=False)
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['complete']

