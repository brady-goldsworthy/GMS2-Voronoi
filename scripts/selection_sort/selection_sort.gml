/// @description selection_sort(array)
/// @param array
function selection_sort(argument0) {

	arr=argument0;

	for(i=0;i<array_length_1d(arr)-1;i++)
	    {
	        var min_=i;
	        for(j=i+1;j<array_length_1d(arr);j++)
	            {
	                if arr[j]<arr[min_]
	                {
	                    min_=j
	                }
	            }
	        arr=swap(arr,i,min_)
	    }

	return arr;



}
