/// @description shaker_sort(array)
/// @param array
function shaker_sort(argument0) {
	var arr=argument0

	var left=0;
	var right=array_length_1d(arr)-1;
	var count=0;

	while(left<=right)
	    {
	        for(i=left;i<right;i++)
	            {
	                count++
	                if arr[i]>arr[i+1]
	                    arr=swap(arr,i,i+1);
	            }
	        right--;
        
	        for(i=right;i>left;i--)
	            {
	                count++;
	                if arr[i-1]>arr[i]
	                    arr=swap(arr,i-1,i);
	            }
	        left++;
	    }
    
	return arr;



}
