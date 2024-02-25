# Welcome to MeteleAPI.

**MeteleAPI** is a project that aims to enable programmers to start implementing an API using **FastAPI** quickly and easily.

**MeteleAPI** aims to help the programmer in repetitive tasks such as:

- Installing Python, its version, creating virtual environments, managing project dependencies, etc.
- Setting up files to run the project within a *Docker* container with *hot-reloading* (yes, changes you make on files are auto-reloaded inside the docker container).
- Defining a structure for the project so you don't have to think where you should write your models, services, and endpoints.

It also comes with *batteries included* as it provides ***services***, which are simple Python modules that provide reusable generic functionalities that are generally necessary when developing an API.

> [!IMPORTANT]
>
> **MeteleAPI** does not make any modifications to the source code of **FastAPI**. When using **MeteleAPI**, you still get to enjoy the excellent experience of programming with **FastAPI**, but now you have several utilities that make starting a new project with **FastAPI** faster and easier.

By using **MeteleAPI** to develop your API with **FastAPI**, you won't have to think or write code for the following tasks anymore:

- Installing the Python version you want to use in this new project and be sure its installed on your system. No more! **MeteleAPI** will take care of installing it, if needed.

- Manually managing project dependencies/requirements. No more dealing with *requirements.txt* files or configuring third-party tools like *Poetry*.

- Writing files for *docker* and *docker compose* and then running your API inside the *docker* container.

- Figuring out how to structure your code, where to write the endpoints, where to write the business logic, etc.

- Writing code to access values defined in the *.env* file on your project. **MeteleAPI** already provides everything you need, so its easy as: 

  ```py 
  from services import settings
  def test():
    if settings.DEBUG:
      ...
  ```

- Setting up logging for your project. Same as before, **MeteleAPI** already provides you with a logger ready to be used:

  ```py 
  from services import logger
  def test():
    logger.info("This is something important")
  ```