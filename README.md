# Coffee Digital - Mapping and Analysis Project 🌱☕

This repository contains R scripts for analyzing and visualizing coffee farm data, including static maps with satellite imagery and interactive web maps. The project focuses on mapping coffee farms across different communities and categories using geographic data.

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
- [Usage](#usage)
- [Scripts Description](#scripts-description)
- [Output Examples](#output-examples)
- [Data](#data)
- [Configuration](#configuration)
- [Contributing](#contributing)

## 🎯 Overview

This project analyzes coffee farm data across different communities and categories, creating both static and interactive visualizations. The analysis includes:

- **Static Maps**: High-quality satellite maps with farm locations
- **Interactive Maps**: Web-based maps with filtering capabilities
- **Community Analysis**: Individual maps for each community
- **Category Visualization**: Different symbols and colors for farm categories

### Key Features

- 🗺️ Satellite imagery integration using Google Maps API
- 📍 Geographic visualization with custom symbols and colors
- 🏘️ Community-based analysis and mapping
- 🎨 Category differentiation through symbols and colors
- 🌐 Interactive web maps with Leaflet
- 📊 Automated map generation for multiple communities

## 📁 Project Structure

```
coffee-digital/
├── README.md                    # Project documentation
├── LICENSE                      # License file
├── .gitignore                  # Git ignore rules
├── config.R.example           # Configuration template
├── config.R                   # API keys (not in version control)
│
├── data/                       # Data directory
│   ├── derived/               # Processed data
│   │   ├── coffee_sample_final_20250709.rds
│   │   └── coffee_sample_final_20250709.xlsx
│   ├── org/                   # Original data files
│   │   ├── 3.Fincas_seleccionadas.xlsx
│   │   ├── Base_vieja.xlsx
│   │   ├── Fincas_actualizado_final2.xlsx
│   │   ├── pioners.xlsx
│   │   └── TREATMENT VS CONTROL_2.R
│   └── Shapes/               # Shapefiles for geographic boundaries
│       ├── shapes.shp
│       ├── shapes.dbf
│       ├── shapes.prj
│       ├── shapes.cpg
│       └── shapes.shx
│
├── syntaxis/                  # R scripts
│   ├── 01_Sampling_Random_Selection.R
│   ├── 02_create_maps.R      # Main mapping script
│   ├── 03_interactive_maps.R # Interactive map creation
│   ├── aux_func_distacia.R   # Distance calculation functions
│   └── old_check_old_ds.R    # Data validation
│
└── out/                      # Output directory (generated)
    ├── map_all.png          # General overview map
    ├── map_[community].png  # Individual community maps
    └── interactive_map.html # Interactive web map
```

## 🛠️ Setup and Installation

### Prerequisites

- R (version 4.0 or higher)
- RStudio (recommended)
- Google Maps API key

### Required R Packages

The project uses `pacman` for package management. The following packages are automatically installed:

```r
# Core packages
- ggplot2      # Data visualization
- ggmap        # Google Maps integration
- sf           # Spatial data handling
- leaflet      # Interactive maps
- htmlwidgets  # Web widgets for R
```

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/coffee-digital.git
   cd coffee-digital
   ```

2. **Set up Google Maps API key:**
   
   **Option A: Environment Variable (Recommended)**
   ```bash
   export GOOGLE_MAPS_API_KEY="your_api_key_here"
   ```
   
   **Option B: Configuration File**
   ```bash
   cp config.R.example config.R
   # Edit config.R and add your API key
   ```

3. **Create output directory:**
   ```bash
   mkdir -p out
   ```

4. **Run the scripts in RStudio or R console**

## 🚀 Usage

### Quick Start

1. **Generate all maps:**
   ```r
   source("syntaxis/02_create_maps.R")
   ```

2. **Create interactive map:**
   ```r
   source("syntaxis/03_interactive_maps.R")
   ```

### Detailed Workflow

1. **Data Preparation:** Load and process coffee farm data
2. **Static Maps:** Generate satellite maps with farm locations
3. **Community Maps:** Create individual maps for each community
4. **Interactive Maps:** Build web-based interactive visualizations

## 📜 Scripts Description

### `01_Sampling_Random_Selection.R`
- **Purpose:** Random sampling and selection of coffee farms
- **Input:** Original data files from `data/org/`
- **Output:** Processed sample data
- **Key Functions:** Statistical sampling, data validation

### `02_create_maps.R` ⭐ **Main Script**
- **Purpose:** Creates static maps with satellite imagery
- **Features:**
  - Google Maps satellite integration
  - Shapefile overlay for geographic boundaries
  - Community-based color coding
  - Category-based symbol differentiation
  - Automated map generation for all communities
- **Outputs:**
  - `out/map_all.png` - Overview map of all farms
  - `out/map_[community].png` - Individual community maps

### `03_interactive_maps.R` 🌐 **Interactive Maps**
- **Purpose:** Creates interactive web-based maps
- **Features:**
  - Leaflet integration for web interactivity
  - Toggle between street and satellite views
  - Color-coded communities
  - Symbol-coded categories
  - Popup information for each farm
  - Legend for easy interpretation
- **Output:** `out/interactive_map.html`

### `aux_func_distacia.R`
- **Purpose:** Distance calculation utilities
- **Functions:** Geographic distance computations between farms

### `old_check_old_ds.R`
- **Purpose:** Data validation and quality checks
- **Functions:** Compare old vs new datasets

## 🎨 Output Examples

### Static Maps

#### Overview Map (`map_all.png`)
- Shows all coffee farms across all communities
- Satellite background with shapefile boundaries
- Color-coded by community
- Symbol-coded by category

#### Community Maps (`map_[community].png`)
Individual maps for each community with:
- Closer zoom level for detailed view
- Category-based color and symbol coding
- Farm locations with coordinates

### Interactive Map (`interactive_map.html`)

Features:
- **Base Layers:** Street view and satellite imagery
- **Interactive Elements:** 
  - Clickable markers with farm information
  - Community color coding
  - Category symbol differentiation
- **Legends:** Clear identification of communities and categories
- **Popups:** Detailed information including:
  - Community name
  - Farm category
  - Geographic coordinates

## 📊 Data

### Farm Categories
- **Demostrativa** ⭐ (Demonstration farms)
- **Al Invest** ▶️ (Investment category)
- **Pioneros** ⏹️ (Pioneer farms)
- **Croppie** 🏠 (Crop-focused farms)
- **Only Platform** ⚙️ (Platform-only participants)
- **Control** 🏁 (Control group)
- **Reemplazo** ⭕ (Replacement farms)
- **Sin Asignar** ❓ (Unassigned)

### Data Sources
- **Primary Dataset:** `coffee_sample_final_20250709.rds`
- **Geographic Boundaries:** Shapefiles in `data/Shapes/`
- **Original Data:** Various Excel files in `data/org/`

## ⚙️ Configuration

### Google Maps API Setup

1. **Get API Key:**
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps JavaScript API
   - Create credentials

2. **Configure in Project:**
   ```r
   # In config.R
   google_maps_api_key <- "YOUR_API_KEY_HERE"
   ```

3. **Security Note:**
   - Never commit API keys to version control
   - Use environment variables in production
   - Restrict API key usage by domain/IP

### Customization Options

- **Map Zoom Levels:** Adjust zoom parameters in scripts
- **Color Schemes:** Modify color palettes for communities/categories
- **Symbol Sets:** Change category symbols in symbol definitions
- **Output Formats:** Adjust map dimensions and file formats

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Follow R coding standards
- Document new functions
- Test with sample data
- Update README for new features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues

1. **Google Maps API Errors:**
   - Check API key validity
   - Verify API quotas
   - Ensure Maps JavaScript API is enabled

2. **Missing Packages:**
   - Run `install.packages("pacman")` first
   - Check R version compatibility

3. **File Path Issues:**
   - Ensure working directory is project root
   - Check file permissions
   - Verify data file existence

### Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review error messages for debugging

---

**Last Updated:** July 9, 2025  
**Project Status:** Active Development  
**R Version:** 4.0+