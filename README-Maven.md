# 📚 Oracle Certified Professional Java SE 17 - Estructura Maven

Este repositorio contiene todos los ejemplos del libro de certificación OCP Java SE 17, organizados con una estructura Maven completa para facilitar la compilación y ejecución.

## 🏗️ Estructura del Proyecto

```
java-se17-ocp-examples/
├── pom.xml                          # POM maestro
├── generate-maven-structure.ps1     # Script de generación automática
├── OCP_Ch01/                        # Capítulo 1
│   ├── pom.xml                      # POM del capítulo
│   ├── Example_1_1/
│   │   ├── pom.xml                  # POM del ejemplo
│   │   ├── Point2D.java
│   │   └── TestPoint2D.java
│   ├── Example_1_5/
│   │   ├── pom.xml
│   │   ├── Point3D.java
│   │   └── TestPoint3D.java
│   └── ...
├── OCP_Ch19/                        # Capítulo 19 (Módulos Java 9+)
│   ├── pom.xml
│   └── Chap19_Examples/
│       └── adviceTopDowne/
│           └── src/
│               ├── model/
│               │   ├── module-info.java
│               │   └── com/passion/model/
│               └── view/
│                   ├── module-info.java
│                   └── com/passion/view/
└── ...
```

## 🚀 Inicio Rápido

### 1. Generar Estructura Completa (Automático)

```powershell
# Ejecutar el script de generación automática
.\generate-maven-structure.ps1
```

Este script creará automáticamente todos los archivos `pom.xml` necesarios para cada capítulo y ejemplo.

### 2. Compilar Todo el Proyecto

```bash
# Compilar todos los ejemplos
mvn clean compile

# Compilar solo los ejemplos básicos (Capítulos 1-10)
mvn clean compile -Pbasic-examples

# Compilar solo los módulos Java 9+ (Capítulos 19-25) 
mvn clean compile -Pmodular-examples
```

### 3. Ejecutar Ejemplos Específicos

```bash
# Navegar al ejemplo deseado
cd OCP_Ch01/Example_1_5

# Compilar y ejecutar
mvn compile exec:java

# O compilar y ejecutar con clase main específica
mvn compile exec:java -Dexec.mainClass="TestPoint3D"
```

## 🎯 Características Especiales

### Manejo de Default Package
Los ejemplos de los primeros capítulos usan el **default package** (sin declaración `package`). La configuración Maven está optimizada para manejar esta situación:

```xml
<build>
    <sourceDirectory>.</sourceDirectory>    <!-- Código en la raíz -->
    <outputDirectory>.</outputDirectory>    <!-- Output en la raíz -->
</build>
```

### Soporte para Módulos Java 9+
Los ejemplos de capítulos avanzados (19-25) utilizan el **sistema de módulos de Java 9+** con `module-info.java`:

```xml
<build>
    <sourceDirectory>src</sourceDirectory>  <!-- Estructura estándar -->
</build>
```

### Limpieza de Archivos .class
Todos los POM incluyen configuración para limpiar archivos `.class` existentes:

```bash
mvn clean  # Elimina archivos .class compilados previamente
```

## 🛠️ Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `mvn clean` | Limpia archivos .class |
| `mvn compile` | Compila todos los módulos |
| `mvn clean compile` | Limpia y compila todo |
| `mvn compile -pl OCP_Ch01` | Compila solo el Capítulo 1 |
| `mvn compile -pl OCP_Ch01/Example_1_5` | Compila un ejemplo específico |
| `mvn exec:java` | Ejecuta el main class del módulo actual |
| `mvn exec:java -Dexec.mainClass="TestPoint3D"` | Ejecuta clase específica |

## 🔧 Configuración

### Requisitos
- **Java 17** (JDK 17)
- **Maven 3.8+**

### Variables del Proyecto
```xml
<properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <maven.compiler.release>17</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

## 📋 Perfiles Maven

### Perfil `basic-examples`
Compila solo los ejemplos básicos (Capítulos 1-10):
```bash
mvn clean compile -Pbasic-examples
```

### Perfil `modular-examples` 
Compila solo los módulos Java 9+ (Capítulos 19-25):
```bash
mvn clean compile -Pmodular-examples
```

## 🗂️ Organización por Tipos de Ejemplos

### Tipo 1: Ejemplos Simples (Example_X_Y)
- **Ubicación**: `OCP_Ch0X/Example_X_Y/`
- **Características**: 
  - Default package (sin `package` declaration)
  - Archivos .java directamente en la raíz
  - Configuración Maven especial para default package

### Tipo 2: Ejemplos Complejos (Chap*_Examples)
- **Ubicación**: `OCP_Ch0X/Chap0X_Examples/`
- **Características**:
  - Packages organizados (`package pkg1;`, `package wizard.spells;`)
  - Imports internos entre packages
  - Estructura de directorios por packages

### Tipo 3: Módulos Java 9+ (Ch19-Ch25)
- **Ubicación**: `OCP_Ch19/Chap19_Examples/*/src/`
- **Características**:
  - Sistema de módulos Java 9+ con `module-info.java`
  - Estructura `src/` estándar
  - Packages jerárquicos (`com.passion.model`, `com.passion.view`)
  - Exports de módulos

## 🚨 Solución de Problemas

### Error: "package does not exist"
Asegúrate de que los imports locales sean correctos y que todos los módulos dependientes estén compilados:
```bash
# Compilar en orden de dependencias
mvn clean compile -pl OCP_Ch06/Chap06_Examples
```

### Error: "No main manifest attribute"
Los ejemplos están configurados para ejecutarse con `exec:java`, no como JAR ejecutables:
```bash
# ❌ No funciona
java -jar target/example-1-5-1.0.0.jar

# ✅ Funciona
mvn exec:java
```

### Error: Archivos .class en conflicto
Limpia los archivos .class existentes antes de compilar con Maven:
```bash
mvn clean compile
```

## 📝 Notas Importantes

1. **Default Package**: Los ejemplos iniciales usan default package intencionalmente para simplicidad didáctica
2. **No Dependencias Externas**: Todo el proyecto usa solo librerías estándar de Java
3. **Independencia**: Cada ejemplo es independiente y puede compilarse/ejecutarse por separado
4. **Compatibilidad Eclipse**: Los archivos `.classpath` y `.project` originales se mantienen para compatibilidad

## 🔗 Enlaces Útiles

- [Maven Getting Started Guide](https://maven.apache.org/guides/getting-started/)
- [Java 17 Documentation](https://docs.oracle.com/en/java/javase/17/)
- [Java Platform Module System](https://www.oracle.com/java/technologies/javase/jdk9-developer-guide.html)

---

**¡Feliz programación con Java SE 17! ☕**