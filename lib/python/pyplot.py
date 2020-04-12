import matplotlib.pyplot as plt

def marbles_plot(x1, x2):
    plt.plot(x1, label = "Robot 1")
    plt.plot(x2, label = "Robot 2")
    plt.xlabel('Steps')
    plt.ylabel('Marbles')
    plt.title('Robots and marbles')
    plt.legend()
    plt.show()
