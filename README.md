# busion
Keep your bash project clean and fusion them to a single file

# What is it used for?
keep your bash project portable and share the same functions across multiple project.
In example:
  You have the same function which is used on multiple scripts. Instead of having a seperate file and sourcing always in the function, 
  which will be complicated to have a portable version of the bash script, because instead of copying on file, you will have to copy two files.
  
  Busion will include the file inside your script and generate a single bash script.
  
# Realtime example
File1:
```
echo "This file will be source"
[[ "busion" == "busion" ]] && echo yeah
```

File2:
```
echo "this file will include busion"
# Busion source file File1
echo "here we go"
```
Now you just need to run busion:

```busion.sh -i File2 -o portable.sh```

