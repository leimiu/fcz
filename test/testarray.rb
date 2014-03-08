
arr={}
arr[:add]="ddd"
p arr


str="aabbcc"

def find(str,c)
  count = 0 
  str.each_char do|s|
    
    if(s == c)
      count +=1
    end
    
  end
  return count
end

p find(str,'a')
p find("测试测试测",'测')

