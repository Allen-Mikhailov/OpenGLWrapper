#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include <fstream>
#include <string>
#include <cstring> 

using namespace std;

int width = 800;
int height = 600;

void framebuffer_size_callback(GLFWwindow* window, int nwidth, int nheight)
{
    width = nwidth;
    height = nheight;
    glViewport(0, 0, nwidth, nheight);
}

char* convert(string str)
{
    return &str[0];
}

char* readFile(string filename)
{
    string total;
    string line;
    ifstream file;
    file.open(filename);
    while (getline(file, line))
    {
        total += line + '\n';
    }

    file.close();

    char* cstr = new char[total.length() + 1];
    std::strcpy(cstr, total.c_str()); //, total.length() + 1
    return cstr;
}

void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

int main()
{
    glfwInit();

    GLFWwindow* window = glfwCreateWindow(width, height, "opengl Test", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    glViewport(0, 0, width, height);

    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);


    // Compiling Shaders

    // Compute Shader
    char* source = readFile("shaders/computeShader.shader");
    GLuint computeShader = glCreateShader(GL_COMPUTE_SHADER);
    glShaderSource(computeShader, 1, &source, NULL);
    glCompileShader(computeShader);

    GLuint computeProgram = glCreateProgram();
    glAttachShader(computeProgram, computeShader);
    glLinkProgram(computeProgram);

    //Using
    glUseProgram(computeProgram);
    glDispatchCompute(width, height, 1);
    glMemoryBarrier(GL_ALL_BARRIER_BITS);

    // [[Window Stuff]]
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    //glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);


    while (!glfwWindowShouldClose(window))
    {
        processInput(window);

        // Render shit
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}