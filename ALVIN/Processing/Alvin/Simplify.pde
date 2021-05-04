/**
 
 * ijeomamotion
 * A cross-mode Processing library for sketching animations with numbers, colors vectors, beziers, curves and more. 
 * http://ekeneijeoma.com/processing/ijeomamotion
 *
 * Copyright (C) 2012 Ekene Ijeoma http://ekeneijeoma.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author      Ekene Ijeoma http://ekeneijeoma.com
 * @modified    05/08/2013
 * @version     5.2 (52)
 */

//package ijeoma.math;

import java.util.ArrayList;


public static class Simplify {


  //I added this - Jer
  public static PVector[] runningAverage (PVector[] points, int bracket) {

    //Trim outliers
    float[] dists = new float[points.length - 1];

    ArrayList<PVector> goodPoints = new ArrayList();
    for (int i = 0; i < points.length-1; i++) {
      float d = points[i].dist(points[i + 1]);
      dists[i] = d; 
      if (d < 5) println("outlier");
    }

    sort(dists);
    println(dists[floor(dists.length/2)]);

    //Average points
    PVector[] newPoints = new PVector[points.length];
    for (int i = 0; i < points.length; i++) {
      int leftEdge = max(0, i - bracket);
      int leftBleed = 0 - (i - bracket);
      int rightEdge = min(points.length - 1, i + bracket);
      PVector av = new PVector();
      int b = 0;
      for (int j = leftEdge; j <rightEdge; j++) {
        av.add(points[j]);
        b++;
      }
      av.div(bracket * 2);
      newPoints[i] = av;
    }

    return(newPoints);
  }


  public static PVector[] simplify(PVector[] points, float tolerance) {
    float sqTolerance = tolerance * tolerance;

    return simplifyDouglasPeucker(points, sqTolerance);
  }

  public static PVector[] simplify(PVector[] points, float tolerance, 
    boolean highestQuality) {
    float sqTolerance = tolerance * tolerance;

    if (!highestQuality)
      points = simplifyRadialDistance(points, sqTolerance);

    points = simplifyDouglasPeucker(points, sqTolerance);

    return points;
  }

  // distance-based simplification
  public static PVector[] simplifyRadialDistance(PVector[] points, float sqTolerance) {
    int len = points.length;

    PVector point = new PVector();
    PVector prevPoint = points[0];

    ArrayList<PVector> newPoints = new ArrayList();
    newPoints.add(prevPoint);

    for (int i = 1; i < len; i++) {
      point = points[i];

      if (getSquareDistance(point, prevPoint) > sqTolerance) {
        newPoints.add(point);
        prevPoint = point;
      }
    }

    if (!prevPoint.equals(point)) {
      newPoints.add(point);
    }

    return newPoints.toArray(new PVector[newPoints.size()]);
  }

  // simplification using optimized Douglas-Peucker algorithm with recursion
  // elimination
  public static PVector[] simplifyDouglasPeucker(PVector[] points, float sqTolerance) {
    int len = points.length;

    Integer[] markers = new Integer[len];

    Integer first = 0;
    Integer last = len - 1;

    float maxSqDist;
    float sqDist;
    int index = 0;

    ArrayList<Integer> firstStack = new ArrayList<Integer>();
    ArrayList<Integer> lastStack = new ArrayList<Integer>();

    ArrayList<PVector> newPoints = new ArrayList<PVector>();

    markers[first] = markers[last] = 1;

    while (last != null) {
      maxSqDist = 0;

      for (int i = first + 1; i < last; i++) {
        sqDist = getSquareSegmentDistance(points[i], points[first], 
          points[last]);

        if (sqDist > maxSqDist) {
          index = i;
          maxSqDist = sqDist;
        }
      }

      if (maxSqDist > sqTolerance) {
        markers[index] = 1;

        firstStack.add(first);
        lastStack.add(index);

        firstStack.add(index);
        lastStack.add(last);
      }

      if (firstStack.size() == 0)
        first = null;
      else
        first = firstStack.remove(firstStack.size() - 1);

      if (lastStack.size() == 0)
        last = null;
      else
        last = lastStack.remove(lastStack.size() - 1);
    }

    for (int i = 0; i < len; i++) {
      if (markers[i] != null)
        newPoints.add(points[i]);
    }

    return newPoints.toArray(new PVector[newPoints.size()]);
  }

  public static float getSquareDistance(PVector p1, PVector p2) {
    float dx = p1.x - p2.x, dy = p1.y - p2.y, dz = p1.z - p2.z;
    return dx * dx + dz * dz + dy * dy;
  }

  // square distance from a point to a segment
  public static float getSquareSegmentDistance(PVector p, PVector p1, PVector p2) {
    float x = p1.x, y = p1.y, z = p1.z;

    float dx = p2.x - x, dy = p2.y - y, dz = p2.z - z;

    float t;

    if (dx != 0 || dy != 0 || dz != 0) {
      t = ((p.x - x) * dx + (p.y - y) * dy) + (p.z - z) * dz
        / (dx * dx + dy * dy + dz * dz);

      if (t > 1) {
        x = p2.x;
        y = p2.y;
        z = p2.z;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
        z += dz * t;
      }
    }

    dx = p.x - x;
    dy = p.y - y;
    dz = p.z - z;

    return dx * dx + dy * dy + dz * dz;
  }
}