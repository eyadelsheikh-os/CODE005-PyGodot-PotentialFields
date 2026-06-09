# pot_forces.py
import numpy as np

def force_attractive(pos: np.ndarray,
                     goal: np.ndarray,
                     decel_point: float = 1.0,
                     gain: float = 1.0) -> np.ndarray:
    """
    Attractive force pulling the robot towards the goal.
    Linear inside a radius of decel_point, constant direction outside.

    Args:
        pos: Array of positions, shape (n_points, 2) or (2,) for single point
        goal: Goal position, shape (2,)
        decel_point: Radius for linear force region
        gain: Force gain/strength
    
    Returns:
        Forces array with same shape as pos
    """
    r = pos - goal
    dist = np.linalg.norm(r)

    if dist <= decel_point:
        F = -gain * r / decel_point
    else:
        F = -gain * (r / dist)
    return F

def test_force_attractive(decel_point: float = 3.0, gain: float = 1.0):
    import matplotlib.pyplot as plt
    # Create grid
    x_grid = np.linspace(0, 10, 20)
    y_grid = np.linspace(0, 10, 20)
    X, Y = np.meshgrid(x_grid, y_grid)
    
    # Goal position
    goal = np.array([5.0, 5.0])
    
    # Initialize force arrays
    U = np.zeros_like(X)
    V = np.zeros_like(Y)
    
    # Evaluate force at each grid point individually
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            pos = np.array([X[i, j], Y[i, j]])
            force = force_attractive(pos, goal, decel_point, gain)
            U[i, j] = force[0]
            V[i, j] = force[1]
    
    # Normalize for quiver
    magnitude = np.hypot(U, V)
    U_norm = U / (magnitude + 1e-6)
    V_norm = V / (magnitude + 1e-6)
    
    # Plot
    fig, ax = plt.subplots(figsize=(8, 10))
    quiver = ax.quiver(X, Y, U_norm, V_norm, magnitude,
                       cmap='viridis', alpha=0.6, scale=15, width=0.008, zorder=1)
    
    # Add colorbar
    cbar = plt.colorbar(quiver, ax=ax, shrink=0.7)
    cbar.set_label('Force Magnitude')
    
    # Add goal marker
    ax.plot(goal[0], goal[1], 'r*', markersize=15, label='Goal')
    ax.legend()
    
    plt.grid()
    plt.show()

def vforce_attractive(pos: np.ndarray,
                      goal: np.ndarray,
                      decel_point: float = 1.0,
                      gain: float = 1.0) -> np.ndarray:
    """
        Vectorized Version
    """
    # Ensure pos is at least 2D
    pos = np.atleast_2d(pos)
    
    # Vector from points to goal
    r = pos - goal
    
    # Compute distances for each point (axis=1 for per-row norm)
    dist = np.linalg.norm(r, axis=1, keepdims=True)
    
    # Avoid division by zero
    dist = np.maximum(dist, 1e-10)
    
    # Create mask for linear region
    mask = (dist <= decel_point)
    
    # Calculate forces using broadcasting
    # Where mask is True: -gain * r / decel_point
    # Where mask is False: -gain * (r / dist)
    F_linear = -gain * r / decel_point
    F_constant = -gain * (r / dist)
    
    # Combine using where (broadcast mask to match r's shape)
    F = np.where(mask, F_linear, F_constant)
    
    # Return with original shape
    return F.squeeze()

def test_vforce_attractive(decel_point: float = 3.0, gain: float = 1.0):
    import matplotlib.pyplot as plt
    
    x_grid = np.linspace(0, 10, 20)
    y_grid = np.linspace(0, 10, 20)
    X, Y = np.meshgrid(x_grid, y_grid)
    
    grid_points = np.stack([X.ravel(), Y.ravel()], axis=-1)  # shape (400, 2)
    
    # Goal position
    goal = np.array([5.0, 5.0])
    F_grid = vforce_attractive(grid_points, goal, decel_point, gain)  # shape (400, 2)
    
    # Reshape back to grid for visualization
    U = F_grid[:, 0].reshape(X.shape)  # shape (20, 20)
    V = F_grid[:, 1].reshape(X.shape)
    
    # Normalize for quiver
    magnitude = np.hypot(U, V)
    U_norm = U / (magnitude + 1e-6)
    V_norm = V / (magnitude + 1e-6)
    
    # Plot
    fig, ax = plt.subplots(figsize=(8, 10))
    quiver = ax.quiver(X, Y, U_norm, V_norm, magnitude,
                       cmap='viridis', alpha=0.6, scale=15, width=0.008, zorder=1)
    
    # Add colorbar
    cbar = plt.colorbar(quiver, ax=ax, shrink=0.7)
    cbar.set_label('Force Magnitude')
    
    # Add goal marker
    ax.plot(goal[0], goal[1], 'r*', markersize=15, label='Goal')
    ax.legend()

    plt.grid()
    plt.show()


def force_repulsive(pos: np.ndarray,  # shape (N, 2) or (2,)
                    pos_obs: np.ndarray,  # shape (2,)
                    r_obs: float, r_buff: float,
                    gain: float = 1.0) -> np.ndarray:
    """
    Repulsive force from a circular obstacle.
    - Inside inner radius: maximum repulsion (gain * direction away).
    - Between inner and outer radius: smooth quadratic transition.
    - Outside outer radius: zero force.
    
    Args:
        pos: Array of positions, shape (N, 2) or (2,) for single point
        pos_obs: Obstacle position, shape (2,)
    
    Returns:
        Forces, shape (N, 2) or (2,)
    """
    rho = pos - pos_obs
    dist = np.linalg.norm(rho)
    r_outer = r_obs + r_buff
    
    if dist >= r_outer:
        return np.array([0.0, 0.0])

    if dist <= r_obs:
        mag = gain*3
    else:
        # Quadratic blending: (1/dist² - 1/ρₒ²) / (1/ρᵢ² - 1/ρₒ²)
        inv_dist2 = 1.0 / dist**2
        inv_outer2 = 1.0 / r_outer**2
        inv_inner2 = 1.0 / r_obs**2
        mag = gain * (inv_dist2 - inv_outer2) / (inv_inner2 - inv_outer2)
    
    direction = rho / dist

    return mag * direction

def test_force_repulsive(r_buff: float = 3.0, gain: float = 1.0):
    import matplotlib.pyplot as plt
    # Create grid
    x_grid = np.linspace(0, 10, 20)
    y_grid = np.linspace(0, 10, 20)
    X, Y = np.meshgrid(x_grid, y_grid)
    
    # Obstacle position and radius
    pos_obs = np.array([5.0, 5.0])
    r_obs = 1.0;  # radius of obstacle
    
    # Initialize force arrays
    U = np.zeros_like(X)
    V = np.zeros_like(Y)
    
    # Evaluate force at each grid point individually
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            pos = np.array([X[i, j], Y[i, j]])
            force = force_repulsive(pos, pos_obs, r_obs, r_buff, gain)
            U[i, j] = force[0]
            V[i, j] = force[1]

    # Normalize for quiver
    magnitude = np.hypot(U, V)
    U_norm = U / (magnitude + 1e-6)
    V_norm = V / (magnitude + 1e-6)
    
    # Plot
    fig, ax = plt.subplots(figsize=(8, 10))
    quiver = ax.quiver(X, Y, U_norm, V_norm, magnitude,
                       cmap='viridis', alpha=0.6, scale=15, width=0.008, zorder=1)
    
    # Add colorbar
    cbar = plt.colorbar(quiver, ax=ax, shrink=0.7)
    cbar.set_label('Force Magnitude')
    
    # Add obstacle circle
    circle = plt.Circle(pos_obs, r_obs, color='red', alpha=0.5, fill=True, zorder=2)
    ax.add_patch(circle)
    # Draw buffer zone circle (optional, for visualization)
    buffer_circle = plt.Circle(pos_obs, r_obs + r_buff, color='red', 
                               alpha=0.1, fill=False, linestyle='--', zorder=1)
    ax.add_patch(buffer_circle)
    # Mark center
    ax.plot(pos_obs[0], pos_obs[1], 'ro', markersize=8, zorder=3)
    
    plt.grid()
    plt.show()

def vforce_repulsive(pos: np.ndarray,      # shape (N, 2)
                     obs_pos: np.ndarray,  # shape (M, 2)
                     r_obs: np.ndarray,    # shape (M,)
                     r_buff: np.ndarray,   # shape (M,)
                     gain: float = 1.0) -> np.ndarray:
    """
    Repulsive force from a circular obstacle for multiple points.
    
    Args:
        pos: Array of positions, shape (N, 2)
        obs_pos: Obstacle positions, shape (M, 2)
        r_obs: Inner radii for each obstacle, shape (M,)
        r_buff: Buffer radii for each obstacle, shape (M,)
        gain: Force gain constant
    
    Returns:
        Forces, shape (N, 2) or (2,)
    """
   # Ensure pos is 2D with shape (N, 2)
    pos = np.array(pos, dtype=float)
    if pos.ndim == 1:
        pos = pos.reshape(1, -1)
    elif pos.ndim == 2:
        pass  # Already correct
    else:
        raise ValueError(f"pos must be 1D or 2D, got shape {pos.shape}")
    
    # Ensure obs_pos is 2D with shape (M, 2)
    obs_pos = np.array(obs_pos, dtype=float)
    if obs_pos.ndim == 1:
        obs_pos = obs_pos.reshape(1, -1)
    elif obs_pos.ndim == 2:
        pass  # Already correct
    else:
        raise ValueError(f"obs_pos must be 1D or 2D, got shape {obs_pos.shape}")
    
    # Verify last dimension is 2
    assert pos.shape[-1] == 2, f"pos last dimension must be 2, got {pos.shape[-1]}"
    assert obs_pos.shape[-1] == 2, f"obs_pos last dimension must be 2, got {obs_pos.shape[-1]}"
    
    N = pos.shape[0]  # Number of points
    M = obs_pos.shape[0]  # Number of obstacles
    
    # Handle r_obs
    if np.isscalar(r_obs):
        r_obs = np.full(M, r_obs, dtype=float)
    else:
        r_obs = np.array(r_obs, dtype=float).flatten()
        if len(r_obs) == 1 and M > 1:
            r_obs = np.full(M, r_obs[0])
        assert len(r_obs) == M, f"r_obs length {len(r_obs)} != M={M}"
    
    # Handle r_buff
    if np.isscalar(r_buff):
        r_buff = np.full(M, r_buff, dtype=float)
    else:
        r_buff = np.array(r_buff, dtype=float).flatten()
        if len(r_buff) == 1 and M > 1:
            r_buff = np.full(M, r_buff[0])
        assert len(r_buff) == M, f"r_buff length {len(r_buff)} != M={M}"
    
    
    # Calculate vectors and distances using broadcasting
    # pos: (N, 1, 2) - obs_pos: (1, M, 2) -> (N, M, 2)
    pos_expanded = pos.reshape(N, 1, 2)
    obs_expanded = obs_pos.reshape(1, M, 2)
    rho = pos_expanded - obs_expanded  # Shape: (N, M, 2)
    
    # Calculate Euclidean distance
    dist = np.sqrt(np.sum(rho**2, axis=2))  # Shape: (N, M)
    
    
    # Calculate outer radius for each obstacle
    r_outer = r_obs + r_buff  # Shape: (M,)
    
    
    # Find which point-obstacle pairs are within influence
    # dist: (N, M), r_outer: (M,) -> broadcast to (N, M)
    inside = dist < r_outer  # Shape: (N, M)
    
    
    if not np.any(inside):
        return np.zeros((N, 2))
    
    # Get indices where force is non-zero
    rows, cols = np.where(inside)
    
    # Initialize forces
    pair_forces = np.zeros((N, M, 2))
    
    # Calculate for each active pair (vectorized per pair)
    for idx in range(len(rows)):
        row = rows[idx]
        col = cols[idx]
        
        dist_ij = dist[row, col]
        r_obs_ij = r_obs[col]
        r_outer_ij = r_outer[col]
        
        # Direction away from obstacle
        if dist_ij < 1e-6:
            direction = np.array([1.0, 0.0])
        else:
            direction = rho[row, col] / dist_ij
        
        # Magnitude calculation
        if dist_ij <= r_obs_ij:
            mag = gain *3
        else:
            inv_dist2 = 1.0 / (dist_ij * dist_ij)
            inv_outer2 = 1.0 / (r_outer_ij * r_outer_ij)
            inv_inner2 = 1.0 / (r_obs_ij * r_obs_ij)
            mag = gain * (inv_dist2 - inv_outer2) / (inv_inner2 - inv_outer2)
        
        pair_forces[row, col] = mag * direction
    
    # Sum forces from all obstacles for each point
    total_forces = np.sum(pair_forces, axis=1)  # Shape: (N, 2)
    
    return total_forces


def test_vforce_repulsive(r_buff: float = np.array([3.0]), gain: float = 1.0):
    import matplotlib.pyplot as plt
    
    x_grid = np.linspace(0, 10, 20)
    y_grid = np.linspace(0, 10, 20)
    X, Y = np.meshgrid(x_grid, y_grid)
    
    grid_points = np.stack([X.ravel(), Y.ravel()], axis=-1)  # shape (400, 2)
    
    # Obstacle position and radius
    pos_obs = np.array([[5.0, 5.0]])
    r_obs = np.array([1.0]);  # radius of obstacle

    F_grid = vforce_repulsive(grid_points, pos_obs, r_obs, r_buff, gain)  # shape (400, 2)
    
    # Reshape back to grid for visualization
    U = F_grid[:, 0].reshape(X.shape)  # shape (20, 20)
    V = F_grid[:, 1].reshape(X.shape)
    
    # Normalize for quiver
    magnitude = np.hypot(U, V)
    U_norm = U / (magnitude + 1e-6)
    V_norm = V / (magnitude + 1e-6)
    
    # Plot
    fig, ax = plt.subplots(figsize=(8, 10))
    quiver = ax.quiver(X, Y, U_norm, V_norm, magnitude,
                       cmap='viridis', alpha=0.6, scale=15, width=0.008, zorder=1)
    
    # Add colorbar
    cbar = plt.colorbar(quiver, ax=ax, shrink=0.7)
    cbar.set_label('Force Magnitude')
    
    # Add Obstacle
    for i, (pos, r) in enumerate(zip(pos_obs, r_obs)):
        # Draw obstacle circle
        circle = plt.Circle(pos, r, color='red', alpha=0.5, fill=True, zorder=2)
        ax.add_patch(circle)
        # Draw buffer zone circle (optional, for visualization)
        buffer_circle = plt.Circle(pos, r + r_buff[i], color='red', 
                                   alpha=0.1, fill=False, linestyle='--', zorder=1)
        ax.add_patch(buffer_circle)
        # Mark center
        ax.plot(pos[0], pos[1], 'ro', markersize=8, zorder=3)

    plt.grid()
    plt.show()



def mforce_repulsive(pos: np.ndarray,      # shape (N, 2)
                     obs_pos: np.ndarray,  # shape (M, 2)
                     r_obs: np.ndarray,    # shape (M,) or (M,1)
                     r_buff: np.ndarray,   # shape (M,) or (M,1)
                     gain: float = 1.0) -> np.ndarray:
    """
    Vectorized repulsive forces from multiple obstacles to multiple points.
    """
    # --- Sanitize inputs ---
    obs_pos = np.atleast_2d(obs_pos)          # ensure (M,2)
    r_obs = np.asarray(r_obs).ravel()        # flatten to (M,)
    r_buff = np.asarray(r_buff).ravel()      # flatten to (M,)
    
    N = pos.shape[0]
    M = obs_pos.shape[0]
    
    # Compute vectors and distances
    rho = pos[:, np.newaxis, :] - obs_pos[np.newaxis, :, :]   # (N, M, 2)
    dist = np.linalg.norm(rho, axis=2)                        # (N, M)
    
    # Outer radius (now 1D)
    r_outer = r_obs + r_buff                                   # (M,)
    # Broadcast to (N, M)
    r_outer_expanded = np.broadcast_to(r_outer, (N, M))
    inside = dist < r_outer_expanded
    
    # Initialize force contributions
    F_pair = np.zeros((N, M, 2))
    
    if not np.any(inside):
        return np.zeros((N, 2))
    
    # Direction away from obstacle
    safe_dist = np.where(dist < 1e-6, 1.0, dist)
    direction = np.where(inside[..., np.newaxis], rho / safe_dist[..., np.newaxis], 0.0)
    zero_mask = (dist < 1e-6) & inside
    if np.any(zero_mask):
        direction[zero_mask] = (1.0, 0.0)
    
    # Magnitude
    r_obs_expanded = np.broadcast_to(r_obs, (N, M))
    mag = np.zeros((N, M))
    
    inner_region = inside & (dist <= r_obs_expanded)
    if np.any(inner_region):
        mag[inner_region] = gain*3
    
    outer_region = inside & (dist > r_obs_expanded)
    if np.any(outer_region):
        inv_dist2 = 1.0 / dist[outer_region]**2
        inv_outer2 = 1.0 / r_outer_expanded[outer_region]**2
        inv_inner2 = 1.0 / r_obs_expanded[outer_region]**2
        mag[outer_region] = gain * (inv_dist2 - inv_outer2) / (inv_inner2 - inv_outer2)
    
    F_pair[inside] = (mag[inside, np.newaxis] * direction[inside])
    total_force = np.sum(F_pair, axis=1)
    return total_force

def test_mforce_repulsive(r_buff: float = np.array([3.0]), gain: float = 1.0):
    import matplotlib.pyplot as plt
    
    x_grid = np.linspace(0, 10, 20)
    y_grid = np.linspace(0, 10, 20)
    X, Y = np.meshgrid(x_grid, y_grid)
    
    grid_points = np.stack([X.ravel(), Y.ravel()], axis=-1)  # shape (400, 2)
    
    # Obstacle position and radius
    pos_obs = np.array([[5.0, 5.0]])
    r_obs = np.array([1.0]);  # radius of obstacle

    F_grid = mforce_repulsive(grid_points, pos_obs, r_obs, r_buff, gain)  # shape (400, 2)
    
    # Reshape back to grid for visualization
    U = F_grid[:, 0].reshape(X.shape)  # shape (20, 20)
    V = F_grid[:, 1].reshape(X.shape)
    
    # Normalize for quiver
    magnitude = np.hypot(U, V)
    U_norm = U / (magnitude + 1e-6)
    V_norm = V / (magnitude + 1e-6)
    
    # Plot
    fig, ax = plt.subplots(figsize=(8, 10))
    quiver = ax.quiver(X, Y, U_norm, V_norm, magnitude,
                       cmap='viridis', alpha=0.6, scale=15, width=0.008, zorder=1)
    
    # Add colorbar
    cbar = plt.colorbar(quiver, ax=ax, shrink=0.7)
    cbar.set_label('Force Magnitude')
    
    # Add Obstacle
    for i, (pos, r) in enumerate(zip(pos_obs, r_obs)):
        # Draw obstacle circle
        circle = plt.Circle(pos, r, color='red', alpha=0.5, fill=True, zorder=2)
        ax.add_patch(circle)
        # Draw buffer zone circle (optional, for visualization)
        buffer_circle = plt.Circle(pos, r + r_buff[i], color='red', 
                                   alpha=0.1, fill=False, linestyle='--', zorder=1)
        ax.add_patch(buffer_circle)
        # Mark center
        ax.plot(pos[0], pos[1], 'ro', markersize=8, zorder=3)

    plt.grid()
    plt.show()













