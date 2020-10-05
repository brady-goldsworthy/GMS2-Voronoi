/// bowyer_watson(pointList[,margin]);
//
//  This script uses the bowyer-watson algorithm for
//  delaunay triangulation.
//
//  This script returns a triangulation list with the
//  following data:
//  
//      For each triangle -
//          Point 1 x value
//          Point 1 y value
//          Point 2 x value
//          Point 2 y value
//          Point 3 x value
//          Point 3 y value
//          Circumcenter x value
//          Circumcenter y value
//          Circumradius
//
//      pointList   ds_list of a series of coordinate pairs
//                  in any order used to make up a mesh
//      margin      optional value to expand the super triangle
//                  to give some room to work
//
//  The returned data can easily be filtered through to use
//  however needed. For example:
//  
//  for(i=0;i<ds_list_size(triangulation);i+=9){ loop through each triangles data
//      triangulation[| 0 to 5] for triangle points
//      triangulation[| 6 to 8] for circumcircle data
//  }
//
/// GMLscripts.com/license
function bowyer_watson() {

var _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _d;
var circumcenter_x, circumcenter_y, circumradius;

var _pointList = argument[0]; //list of points (x1,y1,x2,y2,...,xn,yn)

var _margin = 32;             //margin gives some room to work with for super triangle

if(argument_count>1){
    if(argument[1]>0){ _margin = argument[1]; } //0 or negative will use the default value
}

//first find the aabb of the points to use for the super triangle
var aabb_left   = _pointList[| 0],
    aabb_top    = _pointList[| 1],
    aabb_right  = _pointList[| 0],
    aabb_bottom = _pointList[| 1];

for(var _i = 2; _i < ds_list_size(_pointList); _i += 2){

    if(aabb_left > _pointList[| _i]){ aabb_left = _pointList[| _i]; }
    if(aabb_right < _pointList[| _i]){ aabb_right = _pointList[| _i]; }
    
    if(aabb_top > _pointList[| _i+1]){ aabb_top = _pointList[| _i+1]; }
    if(aabb_bottom < _pointList[| _i+1]){ aabb_bottom = _pointList[| _i+1]; }
}

//add in the margin
aabb_left   -= _margin;
aabb_top    -= _margin;
aabb_right  += _margin;
aabb_bottom += _margin;
    
var _halfWidth = (aabb_right-aabb_left)*0.5;
var _height    = aabb_bottom-aabb_top;

//super triangle
var supTriX1 = aabb_left - _halfWidth,
    supTriY1 = aabb_bottom,
    supTriX2 = aabb_left + _halfWidth,
    supTriY2 = aabb_top - _height,
    supTriX3 = aabb_right + _halfWidth,
    supTriY3 = aabb_bottom;

//triangulation is a list containing 9 values per triangle
var triangulation = ds_list_create();

ds_list_add(triangulation,supTriX1,supTriY1,supTriX2,supTriY2,supTriX3,supTriY3);

_x1 = supTriX1;
_y1 = supTriY1;
_x2 = supTriX2;
_y2 = supTriY2;
_x3 = supTriX3;
_y3 = supTriY3;
    
_d = (_x1 - _x3) * (_y2 - _y3) - (_x2 - _x3) * (_y1 - _y3);

circumcenter_x = (((_x1 - _x3) * (_x1 + _x3) + (_y1 - _y3) * (_y1 + _y3)) / 2 * (_y2 - _y3) 
               -  ((_x2 - _x3) * (_x2 + _x3) + (_y2 - _y3) * (_y2 + _y3)) / 2 * (_y1 - _y3)) 
               / _d;
circumcenter_y = (((_x2 - _x3) * (_x2 + _x3) + (_y2 - _y3) * (_y2 + _y3)) / 2 * (_x1 - _x3)
               -  ((_x1 - _x3) * (_x1 + _x3) + (_y1 - _y3) * (_y1 + _y3)) / 2 * (_x2 - _x3))
               / _d;
               
ds_list_add(triangulation,circumcenter_x,circumcenter_y);
ds_list_add(triangulation,point_distance(_x1,_y1,circumcenter_x,circumcenter_y));

//polygonHole is a list containing 4 values per edge (x1,y1,x2,y2)
polygonHole = ds_list_create();
//badTris is a list containing a pointer to a position in triangulation list for
//a triangle that contains the new point in it's circumcirle
//each value points to the first of the 9 values of the bad triangle
badTris = ds_list_create();

//main loop
for(var _i = 0; _i < ds_list_size(_pointList); _i += 2){

    ds_list_clear(badTris);
    
    //add each point one at a time
    var newPoint_x = _pointList[| _i];
    var newPoint_y = _pointList[| _i+1];
    
    //check each triangle in the triangulation
    for(var _j = 0; _j < ds_list_size(triangulation); _j += 9){
    
        var circumcenter_x = triangulation[| _j+6];
        var circumcenter_y = triangulation[| _j+7];
        var circumradius   = triangulation[| _j+8];
        
        //check if the new point lies within the circumcircle of the current triangle
        if( point_distance(newPoint_x, newPoint_y, circumcenter_x, circumcenter_y) < circumradius){
            ds_list_add(badTris,_j);
        }
    
    }
    
    ds_list_clear(polygonHole);
    
    //now we will compare the edges of the bad triangles to save the edges not touching
    //another bad triangle
    
    //like the name of the list, the edges will make a polygon shaped hole in the triangulation
    
    //for each bad triangle
    for(var _j = 0; _j < ds_list_size(badTris); _j += 1){
    
        var tri1 = badTris[| _j];
        _x1 = triangulation[| tri1+4];
        _y1 = triangulation[| tri1+5];
        
        //for each edge on the current bad triangle
        for(var edgeCheck = 0; edgeCheck < 6; edgeCheck += 2){
        
            edgePass = true;
        
            _x2 = triangulation[| tri1+edgeCheck];
            _y2 = triangulation[| tri1+edgeCheck+1];
            
            //for every other bad triangle
            for(var _k = 0; _k < ds_list_size(badTris) and edgePass; _k += 1){
            
                if(_k == _j){ continue; }
                var tri2 = badTris[| _k];
                _x3 = triangulation[| tri2+4];
                _y3 = triangulation[| tri2+5];
                
                //check to see if the edges match
                for(var edgeCheck2 = 0; edgeCheck2 < 6 and edgePass; edgeCheck2 += 2){
                
                    _x4 = triangulation[| tri2+edgeCheck2];
                    _y4 = triangulation[| tri2+edgeCheck2+1];
                    
                    //we check both ways because edges may be flipped on each other
                    if(_x1 == _x3 and _y1 == _y3 and _x2 == _x4 and _y2 == _y4){
                        edgePass = false;
                    } else {
                    if(_x2 == _x3 and _y2 == _y3 and _x1 == _x4 and _y1 == _y4){
                        edgePass = false;
                    }}
                    _x3 = _x4;
                    _y3 = _y4;
                }
            
            }
            if(edgePass){
                ds_list_add(polygonHole,_x1,_y1,_x2,_y2);
            }
            _x1 = _x2;
            _y1 = _y2;
        }
    
    }
    
    //we saved the edges already so we can discard the bad triangles

    while(!ds_list_empty(badTris)){
    
        var curTri = badTris[| ds_list_size(badTris)-1];
        
        repeat(9){
            ds_list_delete(triangulation,curTri);
        }
        
        ds_list_delete(badTris,ds_list_size(badTris)-1);
    
    }
    
    //now with the edges, we connect our new point to them and make new triangles
    
    for(var _j = 0; _j < ds_list_size(polygonHole); _j += 4){
    
        _x1 = polygonHole[| _j];
        _y1 = polygonHole[| _j+1];
        _x2 = polygonHole[| _j+2];
        _y2 = polygonHole[| _j+3];
        _x3 = newPoint_x;
        _y3 = newPoint_y;
    
        _d = (_x1 - _x3) * (_y2 - _y3) - (_x2 - _x3) * (_y1 - _y3);

        circumcenter_x = (((_x1 - _x3) * (_x1 + _x3) + (_y1 - _y3) * (_y1 + _y3)) / 2 * (_y2 - _y3) 
                       -  ((_x2 - _x3) * (_x2 + _x3) + (_y2 - _y3) * (_y2 + _y3)) / 2 * (_y1 - _y3)) 
                       / _d;
        circumcenter_y = (((_x2 - _x3) * (_x2 + _x3) + (_y2 - _y3) * (_y2 + _y3)) / 2 * (_x1 - _x3)
                       -  ((_x1 - _x3) * (_x1 + _x3) + (_y1 - _y3) * (_y1 + _y3)) / 2 * (_x2 - _x3))
                       / _d;
        circumradius   = point_distance(_x1,_y1,circumcenter_x,circumcenter_y);
        ds_list_add(triangulation,_x1,_y1,_x2,_y2,newPoint_x,newPoint_y);
        ds_list_add(triangulation,circumcenter_x,circumcenter_y,circumradius);
    
    }

}

//now we just need to remove anything connected to the super triangle

for(var _i = 0; _i < ds_list_size(triangulation); _i += 9){
    
    for(var _j = 0; _j < 6; _j += 2){
    
        if(triangulation[| _i+_j] == supTriX1 and triangulation[| _i+_j+1] == supTriY1){
            ds_list_add(badTris,_i);
            _j = 6;
            continue;
        }
        if(triangulation[| _i+_j] == supTriX2 and triangulation[| _i+_j+1] == supTriY2){
            ds_list_add(badTris,_i);
            _j = 6;
            continue;
        }
        if(triangulation[| _i+_j] == supTriX3 and triangulation[| _i+_j+1] == supTriY3){
            ds_list_add(badTris,_i);
            _j = 6;
            continue;
        }
    
    }
}

while(!ds_list_empty(badTris)){

    var curTri = badTris[| ds_list_size(badTris)-1];
    
    repeat(9){
        ds_list_delete(triangulation,curTri);
    }
    
    ds_list_delete(badTris,ds_list_size(badTris)-1);

}

//cleanup
ds_list_destroy(polygonHole);
ds_list_destroy(badTris);

return triangulation;

}