from vispy.scene.visuals import Mesh

from .clipping_planes_mixin import ClippingPlanesMixin


class VectorsVisual(ClippingPlanesMixin, Mesh):
    """
    Vectors vispy visual with clipping plane functionality
    """
