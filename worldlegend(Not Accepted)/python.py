import numpy as np

# Trapezoidal Method
import numpy as np
 
def my_function(*args, **kwargs):
    tempx = Element('test-input-1').element.value
    tempy = Element('test-input-2').element.value
    tempx = np.array(list(tempx))
    tempy = np.array(list(tempy))
    ints = []
    x = []
    y = []
    # checking for missing points
    for (x1, y1) in zip(x, y):
        if(x1.isalpha() or y1.isalpha()):
          if(((len(x)-2) >= 0) and (x[len(x) - 2] == 0 or y[len(y) - 2])):
            x[len(x)-1] = 0
            y[len(y)-1] = 0
          x.append(0)
          y.append(0)
        else:
          x.append(int(x1))
          y.append(int(y1))
    console.log(f'x: {x}')
    console.log(f'y: {y}')
    output = np.trapz(y,x)
    Element('test-output').element.innerText = str(output)