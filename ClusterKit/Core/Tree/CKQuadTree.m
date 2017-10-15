// CKQuadTree.m
//
// Copyright © 2017 Hulab. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CKQuadTree.h"

/// Quadtree point
typedef struct hb_qpoint {
    MKMapPoint point;
    __unsafe_unretained id<MKAnnotation> annotation;
    struct hb_qpoint *next;
} hb_qpoint_t;

/// Quadtree node
typedef struct hb_qnode {
    NSUInteger cap;         ///< Capacity of the node
    NSUInteger cnt;         ///< Number of point in the node
    MKMapRect bound;        ///< Area covered by the node
    hb_qpoint_t *points;    ///< Chained list of node's points
    struct hb_qnode *nw;    ///< NW quadrant of the node
    struct hb_qnode *ne;    ///< NE quadrant of the node
    struct hb_qnode *sw;    ///< SW quadrant of the node
    struct hb_qnode *se;    ///< SE quadrant of the node
} hb_qnode_t;

/// Quadtree container
typedef struct hb_qtree {
    hb_qnode_t *root;   ///< Root node
} hb_qtree_t;

static hb_qnode_t *hb_qnode_new(MKMapRect bound, NSUInteger capacity) {
    hb_qnode_t *n = malloc(sizeof(hb_qnode_t));
    memset(n, 0, sizeof(hb_qnode_t));
    
    n->bound = bound;
    n->cap = capacity;
    return n;
}

static void hb_qpoint_free(hb_qpoint_t *p) {
    if (p) {
        hb_qpoint_free(p->next);
        free(p);
    }
}

static void hb_qnode_free(hb_qnode_t *n) {
    hb_qpoint_free(n->points);
    n->cnt = 0;
    
    if(n->nw) {
        hb_qnode_free(n->nw);
        hb_qnode_free(n->ne);
        hb_qnode_free(n->sw);
        hb_qnode_free(n->se);
    }
    free(n);
}

static void add_(hb_qnode_t *n, hb_qpoint_t *p) {
    p->next = n->points;
    n->points = p;
    n->cnt++;
}

static bool drop_(hb_qnode_t *n, id<MKAnnotation> a) {
    
    for (hb_qpoint_t *cur = n->points , *prev = NULL;
         cur != NULL;
         prev = cur, cur = cur->next) {
        
        if (cur->annotation == a) {
            if (prev == NULL) {
                n->points = cur->next;
            } else {
                prev->next = cur->next;
            }
            free(cur);
            n->cnt--;
            return true;
        }
    }
    return false;
}

static void subdivide_(hb_qnode_t *n) {
    MKMapRect bd = n->bound;
    MKMapRect nw;
    MKMapRect ne;
    MKMapRect sw;
    MKMapRect se;
    
    MKMapRectDivide(bd, &nw, &ne, MKMapRectGetWidth (bd) / 2, CGRectMaxXEdge);
    MKMapRectDivide(nw, &nw, &sw, MKMapRectGetHeight(nw) / 2, CGRectMaxYEdge);
    MKMapRectDivide(ne, &ne, &se, MKMapRectGetHeight(ne) / 2, CGRectMaxYEdge);
    
    n->nw = hb_qnode_new(nw, n->cap);
    n->ne = hb_qnode_new(ne, n->cap);
    n->sw = hb_qnode_new(sw, n->cap);
    n->se = hb_qnode_new(se, n->cap);
}

static bool hb_qnode_insert(hb_qnode_t *n, id<MKAnnotation> a) {

    MKMapPoint point = MKMapPointForCoordinate(a.coordinate);
    if(!MKMapRectContainsPoint(n->bound, point))
        return false;
    
    if(n->cnt < n->cap) {
        hb_qpoint_t *p = malloc(sizeof(hb_qpoint_t));
        p->annotation = a;
        p->point = point;
        add_(n, p);
        return true;
    }
    
    if(!n->nw) {
        subdivide_(n);
    }
    
    if(hb_qnode_insert(n->nw, a)) return true;
    if(hb_qnode_insert(n->ne, a)) return true;
    if(hb_qnode_insert(n->sw, a)) return true;
    if(hb_qnode_insert(n->se, a)) return true;
    
    return false;
}

static bool hb_qnode_remove(hb_qnode_t *n, id<MKAnnotation> a) {
    
    if(drop_(n, a)) {
        return true;
    }
    
    if(n->nw) {
        if(hb_qnode_remove(n->nw, a)) return true;
        if(hb_qnode_remove(n->ne, a)) return true;
        if(hb_qnode_remove(n->sw, a)) return true;
        if(hb_qnode_remove(n->se, a)) return true;
    }
    return false;
}

static void hb_qnode_get_in_range(hb_qnode_t *n, MKMapRect range, void(^find)(id<MKAnnotation>annotation)) {
    
    if(n->cnt) {
        if(!MKMapRectIntersectsRect(n->bound, range))
            return;
        
        hb_qpoint_t *p = n->points;
        while (p) {
            if(MKMapRectContainsPoint(range, p->point)) {
                find(p->annotation);
            }
            p = p->next;
        }
    }
    
    if(n->nw) {
        hb_qnode_get_in_range(n->nw, range, find);
        hb_qnode_get_in_range(n->ne, range, find);
        hb_qnode_get_in_range(n->sw, range, find);
        hb_qnode_get_in_range(n->se, range, find);
    }
}

/* publics */

hb_qtree_t *hb_qtree_new(MKMapRect rect, NSUInteger cap) {
    hb_qtree_t *t = malloc(sizeof(hb_qtree_t));
    t->root = hb_qnode_new(rect, cap);
    return t;
}

void hb_qtree_free(hb_qtree_t *t) {
    if(t->root) hb_qnode_free(t->root);
    free(t);
}

void hb_qtree_insert(hb_qtree_t *t, id<MKAnnotation> annotation) {
    hb_qnode_insert(t->root, annotation);
}

void hb_qtree_remove(hb_qtree_t *t, id<MKAnnotation> annotation) {
    hb_qnode_remove(t->root, annotation);
}

void hb_qtree_clear(hb_qtree_t *t) {
    MKMapRect bound = t->root->bound;
    NSUInteger cap  = t->root->cap;
    hb_qnode_free(t->root);
    t->root = hb_qnode_new(bound, cap);
}

void hb_qtree_find_in_range(hb_qtree_t *t, MKMapRect range , void(^find)(id<MKAnnotation>annotation)) {
    hb_qnode_get_in_range(t->root, range, find);
}

@interface CKQuadTree ()
@property (nonatomic, copy) NSArray *annotations;
@property (nonatomic, assign) hb_qtree_t *tree;
@end

@implementation CKQuadTree {
    BOOL _responds;
}

static void * const CKQuadTreeKVOContext = (void *)&CKQuadTreeKVOContext;

@synthesize delegate = _delegate;

- (instancetype)init {
    return [self initWithAnnotations:[NSArray array]];
}

- (instancetype)initWithAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    self = [super init];
    if (self) {
        self.annotations = annotations;
        
        self.tree = hb_qtree_new(MKMapRectWorld, CK_QTREE_STDCAP);
        
        for (NSObject<MKAnnotation> *annotation in annotations) {
            hb_qtree_insert(self.tree, annotation);
            
            [annotation addObserver:self
                         forKeyPath:NSStringFromSelector(@selector(coordinate))
                            options:NSKeyValueObservingOptionNew
                            context:CKQuadTreeKVOContext];
        }
    }
    return self;
}

- (NSArray<id<MKAnnotation>> *)annotationsInRect:(MKMapRect)rect {
    NSMutableArray *results = [NSMutableArray new];
    
    // For map rects that span the 180th meridian, we get the portion outside the world.
    if (MKMapRectSpans180thMeridian(rect)) {
        
        hb_qtree_find_in_range(self.tree, MKMapRectRemainder(rect), ^(id<MKAnnotation> annotation) {
            if (!self->_responds || [self.delegate annotationTree:self shouldExtractAnnotation:annotation]) {
                [results addObject:annotation];
            }
        });
        
        rect = MKMapRectIntersection(rect, MKMapRectWorld);
    }
    
    hb_qtree_find_in_range(self.tree, rect, ^(id<MKAnnotation> annotation) {
        if (!self->_responds || [self.delegate annotationTree:self shouldExtractAnnotation:annotation]) {
            [results addObject:annotation];
        }
    });
    
    return results;
}

- (void)setDelegate:(id<CKAnnotationTreeDelegate>)delegate {
    _delegate = delegate;
    
    //Cache whether the delegate responds to a selector
    _responds = [self.delegate respondsToSelector:@selector(annotationTree:shouldExtractAnnotation:)];
}

- (void)dealloc {
    for (NSObject<MKAnnotation> *annotation in self.annotations) {
        [annotation removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(coordinate))
                           context:CKQuadTreeKVOContext];
    }
    
    hb_qtree_free(self.tree);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == CKQuadTreeKVOContext) {
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(coordinate))]) {
            hb_qtree_remove(self.tree, object);
            hb_qtree_insert(self.tree, object);
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
