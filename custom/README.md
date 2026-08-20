## UAV DAA Thesis Customization

This fork of QGroundControl contains a minimal visualization extension developed for the UAV detect-and-avoid thesis project.

The custom Fly View overlay displays two horizontal protected-volume footprints associated with the ownship UAV:

- **Solid blue circle:** current horizontal footprint of the project-defined protected volume, centred on the active vehicle.
- **Dashed blue circle:** The dashed blue circle represents a 45 s constant-velocity projection based only on the active vehicle's current ground speed and heading. It is intended as a kinematic motion-context indicator and does not represent the trajectory or future position selected by the tactical resolver.
- horizontal protected-volume radius: **152.4 m (500 ft)**
- vertical half-height used by the DAA logic: **30.48 m (100 ft)**

Only the horizontal footprint is represented on the 2D QGroundControl map.

The projected dashed circle is a kinematic visualization of the vehicle state at the current instant. It does not represent the trajectory selected by the tactical resolver or an additional separation/protection layer.

Both visualizations update continuously as the active vehicle moves.

The DAA-specific implementation is intentionally isolated under:

```text
custom/
├── CMakeLists.txt
├── README.md
├── cmake/
│   └── CustomOverrides.cmake
└── src/
    ├── DAACorePlugin.cc
    ├── DAACorePlugin.h
    └── FlyViewCustomLayer.qml
```

### Start QGroundControl

Activate the dedicated QGroundControl build environment:

```bash
source ~/qgc-build-venv/bin/activate
```

Then start the custom QGroundControl build:

```bash
cd ~/qgroundcontrol-daa
./build/Debug/QGroundControl
```

### PX4 SITL Test

In a separate terminal, start PX4 SITL with the x500 vehicle:

```bash
cd ~/PX4-Autopilot
make px4_sitl gz_x500
```

Once the vehicle connects to QGroundControl, the solid blue **152.4 m protected-volume circle** should remain centred on and move with the active vehicle, while the dashed blue circle should indicate the corresponding **45 s constant-velocity projected footprint**.
