# Script simplificado para generar estructura Maven completa
Write-Host "🚀 Generando estructura Maven para proyecto OCP Java SE 17..." -ForegroundColor Green

# Función para crear pom.xml de capítulo
function Create-ChapterPom {
    param ([string]$chapterPath, [string]$chapterNumber, [array]$modules)

    $pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.ocp.book</groupId>
        <artifactId>java-se17-ocp-examples</artifactId>
        <version>1.0.0</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>ocp-ch$chapterNumber-examples</artifactId>
    <packaging>pom</packaging>
    <name>OCP Chapter $chapterNumber Examples</name>

    <modules>
"@
    foreach ($module in $modules) {
        $pomContent += "`n        <module>$module</module>"
    }
    $pomContent += "`n    </modules>`n</project>"

    $pomPath = Join-Path $chapterPath "pom.xml"
    Set-Content -Path $pomPath -Value $pomContent -Encoding UTF8
    Write-Host "✅ Creado: $pomPath" -ForegroundColor Green
}

# Función para crear pom.xml de ejemplo
function Create-ExamplePom {
    param ([string]$examplePath, [string]$exampleId, [string]$mainClass = $null)

    $chapterMatch = ($examplePath | Select-String "OCP_Ch(\d+)").Matches[0].Groups[1].Value
    $chapterNum = [int]$chapterMatch

    $pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.ocp.book</groupId>
        <artifactId>ocp-ch$('{0:D2}' -f $chapterNum)-examples</artifactId>
        <version>1.0.0</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>$exampleId</artifactId>
    <packaging>jar</packaging>
    <name>$exampleId</name>

    <build>
        <sourceDirectory>.</sourceDirectory>
        <outputDirectory>.</outputDirectory>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <includes><include>**/*.java</include></includes>
                    <excludes><exclude>**/*.class</exclude></excludes>
                </configuration>
            </plugin>
"@
    if ($mainClass) {
        $pomContent += @"

            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>exec-maven-plugin</artifactId>
                <configuration>
                    <mainClass>$mainClass</mainClass>
                </configuration>
            </plugin>
"@
    }
    $pomContent += @"

        </plugins>
    </build>
</project>
"@

    $pomPath = Join-Path $examplePath "pom.xml"
    Set-Content -Path $pomPath -Value $pomContent -Encoding UTF8
    Write-Host "✅ Creado: $pomPath" -ForegroundColor Green
}

# Función para detectar clase main
function Find-MainClass {
    param ([string]$path)
    $javaFiles = Get-ChildItem -Path $path -Filter "*.java" -ErrorAction SilentlyContinue
    foreach ($file in $javaFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match "public\s+static\s+void\s+main\s*\(\s*String\s*\[\s*\]\s*\w+\s*\)") {
            return $file.BaseName
        }
    }
    return $null
}

# PROCESO PRINCIPAL
$rootPath = Get-Location
Write-Host "📁 Directorio raíz: $rootPath" -ForegroundColor Cyan

# Obtener todos los directorios de capítulos  
$chapterDirs = Get-ChildItem -Directory | Where-Object { $_.Name -match "^OCP_Ch\d+$" } | Sort-Object Name

foreach ($chapterDir in $chapterDirs) {
    Write-Host "`n📚 Procesando $($chapterDir.Name)..." -ForegroundColor Yellow
    
    $chapterNumber = ($chapterDir.Name | Select-String "OCP_Ch(\d+)").Matches[0].Groups[1].Value
    $chapterNumberPadded = "{0:D2}" -f [int]$chapterNumber
    
    # Obtener subdirectorios (ejemplos)
    $exampleDirs = Get-ChildItem -Path $chapterDir.FullName -Directory | Sort-Object Name
    $modules = @()
    
    foreach ($exampleDir in $exampleDirs) {
        $modules += $exampleDir.Name
        
        # Crear pom.xml para el ejemplo
        $mainClass = Find-MainClass -path $exampleDir.FullName
        $exampleId = $exampleDir.Name.ToLower() -replace "_", "-"
        
        Create-ExamplePom -examplePath $exampleDir.FullName -exampleId $exampleId -mainClass $mainClass
    }
    
    # Crear pom.xml para el capítulo
    Create-ChapterPom -chapterPath $chapterDir.FullName -chapterNumber $chapterNumberPadded -modules $modules
}

Write-Host "`n🎉 ¡Estructura Maven generada completamente!" -ForegroundColor Green
Write-Host "💡 Ahora ejecuta: mvn clean compile" -ForegroundColor Cyan