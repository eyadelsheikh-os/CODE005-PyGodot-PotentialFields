# plot_elements.py
import numpy as np
from matplotlib.patches import Circle, FancyArrowPatch

# =============================================================================
# AXIS SETUP
# =============================================================================
def setup_axes(ax, x_lim=None, y_lim=None, x_label='X (m)', y_label='Y (m)',
               title=None, equal_aspect=True, grid=True):
    """Configure axes limits, labels, grid and aspect."""
    if x_lim is not None:
        ax.set_xlim(x_lim)
    if y_lim is not None:
        ax.set_ylim(y_lim)
    if equal_aspect:
        ax.set_aspect('equal')
    if grid:
        ax.grid(True, linestyle='--', alpha=0.5)
    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    if title:
        ax.set_title(title)
    return ax


def auto_limits(x, y, robot_radius, margin_factor=3.0, min_margin=1.0):
    """Compute axis limits from trajectory with a margin around the robot."""
    margin = max(robot_radius * margin_factor, min_margin)
    x_lim = (np.min(x) - margin, np.max(x) + margin)
    y_lim = (np.min(y) - margin, np.max(y) + margin)
    return x_lim, y_lim


# =============================================================================
# ROBOT COMPONENTS
# =============================================================================
def add_robot_circle(ax, x0, y0, radius, facecolor='white', edgecolor='black',
                     linewidth=2, zorder=3):
    """Add robot as a circle patch and return it."""
    robot = Circle((x0, y0), radius, fc=facecolor, ec=edgecolor,
                   lw=linewidth, zorder=zorder)
    ax.add_patch(robot)
    return robot


def add_orientation_arrow(ax, x0, y0, theta0, arrow_length, arrow_style='->',
                          color='black', linewidth=2, zorder=4):
    """Add an arrow showing robot orientation (line + head)."""
    dx = arrow_length * np.cos(theta0)
    dy = arrow_length * np.sin(theta0)
    line, = ax.plot([x0, x0 + dx], [y0, y0 + dy], color=color,
                    lw=linewidth, zorder=zorder)
    head = FancyArrowPatch((x0 + dx, y0 + dy), (x0 + dx * 0.7, y0 + dy * 0.7),
                           arrowstyle=arrow_style, color=color,
                           lw=linewidth, zorder=zorder)
    ax.add_patch(head)
    return line, head


def update_robot(robot_patch, orientation_line, orientation_head,
                 x, y, theta, arrow_length):
    """Update robot position and orientation for a given frame index."""
    robot_patch.center = (x, y)
    dx = arrow_length * np.cos(theta)
    dy = arrow_length * np.sin(theta)
    orientation_line.set_data([x, x + dx], [y, y + dy])
    orientation_head.set_positions((x + dx, y + dy), (x + dx * 0.7, y + dy * 0.7))
    return [robot_patch, orientation_line, orientation_head]


def add_trail(ax, x0, y0, color='blue', linewidth=2, alpha=0.7, zorder=1):
    """Create an empty line for the robot trail."""
    trail, = ax.plot([x0], [y0], color=color, lw=linewidth,
                     alpha=alpha, zorder=zorder)
    return trail


def update_trail(trail, x_arr, y_arr, frame_idx):
    """Update trail with all positions up to current frame."""
    trail.set_data(x_arr[:frame_idx + 1], y_arr[:frame_idx + 1])
    return [trail]


# =============================================================================
# TEXT PANEL
# =============================================================================
def add_text_panel(ax, fontsize=10, bg_alpha=0.7):
    """Add text boxes for throttle, steering and time title."""
    throttle_text = ax.text(0.02, 0.98, '', transform=ax.transAxes,
                            fontsize=fontsize, verticalalignment='top',
                            bbox=dict(boxstyle='round', facecolor='white', alpha=bg_alpha))
    steering_text = ax.text(0.02, 0.92, '', transform=ax.transAxes,
                            fontsize=fontsize, verticalalignment='top',
                            bbox=dict(boxstyle='round', facecolor='white', alpha=bg_alpha))
    return throttle_text, steering_text


def update_text(throttle_text, steering_text, throttle_val, steering_val,
                time_sec=None, time_title=None):
    """Update throttle, steering and optionally the title."""
    throttle_text.set_text(f'Throttle: {throttle_val:.2f}')
    steering_text.set_text(f'Steering: {steering_val:.2f}')
    if time_title is not None and time_sec is not None:
        time_title.set_text(f'Robot Motion At Time = {time_sec:.2f} sec')
    return [throttle_text, steering_text] + ([time_title] if time_title else [])


# =============================================================================
# GOAL MARKER (dynamic)
# =============================================================================
def add_goal_marker(ax, x0, y0, marker='y*', markersize=15, zorder=5):
    """Add a marker for the goal (position can be updated later)."""
    marker_line, = ax.plot([x0], [y0], marker, markersize=markersize, zorder=zorder)
    return marker_line


def update_goal_marker(marker, x, y):
    """Update goal marker position."""
    marker.set_data([x], [y])
    return [marker]


# =============================================================================
# OBSTACLES (dynamic, per frame)
# =============================================================================
def draw_obstacles(ax, obstacle_list):
    """
    Remove any existing obstacle patches from ax and draw new ones.
    Returns a list of new patch objects.
    """
    # Remove previously drawn obstacles (stored in ax.obstacle_patches)
    if hasattr(ax, 'obstacle_patches'):
        for p in ax.obstacle_patches:
            p.remove()
    # Draw new obstacles
    patches = []
    if obstacle_list is not None and len(obstacle_list) > 0:
        for obs in obstacle_list:
            if obs is not None and len(obs) >= 3:
                cx, cy, rad = obs[:3]
                circ = Circle((cx, cy), rad, fc='red', ec='black',
                              alpha=0.6, lw=1.5, zorder=2)
                ax.add_patch(circ)
                patches.append(circ)
    ax.obstacle_patches = patches
    return patches









