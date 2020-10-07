/// @description gnome_sort(array)
/// @param array
function gnome_sort(argument0) {
	//my favorite sort:DDDDD

	var arr=argument0;

	var i=1;
	var j=2;

	while(i<array_length_1d(arr))
	    {
	        if arr[i-1]<arr[i]//if you need sort biggest-lowest set > expression
	            {
	                i=j;
	                j=j+1;
	            }else{
	                arr=swap(arr,i-1,i)
	                i=i-1
	                if i=0
	                    {
	                        i=j;
	                        j=j+1;
	                    }
	            }
	    }

	return arr;



}
