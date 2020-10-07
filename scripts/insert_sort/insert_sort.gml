/// @description insert_sort(array)
/// @param array
function insert_sort(argument0) {
	//simplest soring algorithm

	arr=argument0;

	for(i=1;i<array_length_1d(arr);i++)
	    {
	        for(j=i;j>0;j--)
	            {
	                if arr[j-1]>arr[j]
	                    arr=swap(arr,j-1,j);
	                else
	                    break;
	            }
	    }

	return arr;



}
