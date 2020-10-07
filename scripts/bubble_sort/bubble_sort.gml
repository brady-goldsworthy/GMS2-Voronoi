/// @description bubble_sort(array)
/// @param array
function bubble_sort(argument0) {

	arr=argument0;
	swapped=true;
	j=0;
	var tmp;

	while(swapped)
	    {
	        swapped=false;
	        j++
	        for(i=0;i<array_length_1d(arr)-j;i++)
	            {
	                if arr[i]>arr[i+1]
	                    {
	                        arr=swap(arr,i,i+1)
	                        swapped=true;
	                    }
	            }
	    }

	return arr;



}
