/// @description comb_sort(array)
/// @param array
function comb_sort(argument0) {
	arr=argument0;

	var n=0;
	var fakt=1.2473309;
	var step=array_length_1d(arr)-1;

	while(step>=1)
	    {
	        for(i=0;i+step<array_length_1d(arr);i++)
	            {
	                if arr[i]>arr[i+step]
	                    {
	                        arr=swap(arr,i,i+step);
	                        n++;
	                    }
	            }
	        step /= fakt;
	    }
	    //now bubble sort
	for(i=0;i<array_length_1d(arr)-1;i++)
	    {
	        var swapped=false;
	        for(j=0;j<array_length_1d(arr)-i-1;j++)
	            {
	                if arr[j]>arr[j+1]
	                    {
	                        arr=swap(arr,arr[j],arr[j+1])
	                        swapped=true;
	                        n++;
	                    }
	            }
	            if !swapped
	                break;
	    }

	return arr;



}
