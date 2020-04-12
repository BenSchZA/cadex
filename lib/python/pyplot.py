import matplotlib.pyplot as plt

def marbles_plot(x1, x2):
    plt.plot(x1, label = "Robot 1")
    plt.plot(x2, label = "Robot 2")
    plt.xlabel('Steps')
    plt.ylabel('Marbles')
    plt.title('Robots and marbles')
    plt.legend()
    plt.show()

def plot_marble_runs(x1_runs, x2_runs):
    for x1_run in x1_runs:
        plt.plot(x1_run)
    for x2_run in x2_runs:
        plt.plot(x2_run)
    plt.xlabel('Steps')
    plt.ylabel('Marbles')
    plt.title('Robots and marbles')
    plt.legend()
    plt.show()