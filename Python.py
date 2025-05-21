# Intersection of Lists/Sets
def intersection(a, b):
  return list(set(a) & set(b))

# --------------------------------------------------------------------------------------------------------
# Weakest Strong Link : Find weakest in each row, but strongest in each column
# I/P: strength = [[1, 2, 3],[4, 5, 6],[7, 8, 9]]
# O/P: 7 : Weakest in [7, 8, 9]; Strongest in [1, 4, 7]

def weakest_strong_link(strength):
    rows = len(strength)
    cols = len(strength[0])
    
    for i in range(rows):
        for j in range(cols):
            if strength[i][j] == min(strength[i]) & strength[i][j] == max([row[j] for row in strength]):
                return strength[i][j]

    return -1
  
# --------------------------------------------------------------------------------------------------------
# Example #1
# Input: digits = [1, 2, 3]
# Output: [1, 2, 4]
# Example #2
# Input: digits = [6, 9]
# Output: [7, 0]

def another_one(digits):
  num = ''.join(str(d) for d in digits)
  op_num = int(num) + 1
  return [int(d) for d in str(op_num)]

# --------------------------------------------------------------------------------------------------------
# Write a function fizz_buzz_sum to find the sum of all multiples of 3 or 5 below a target value.
# For example, if the target value was 10, the multiples of 3 or 5 below 10 are 3, 5, 6, and 9.
# Because 3+5+6+9=23, our function would return 23.

def fizz_buzz_sum(target):
  ls = [i for i in range(1,target) if (i%3 == 0) or (i%5 ==0)]
  return sum(ls)
  
# --------------------------------------------------------------------------------------------------------




















