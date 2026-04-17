# Script para generar automáticamente todos los archivos pom.xml
# para el proyecto Oracle Certified Professional Java SE 17

Write-Host "🚀 Generando estructura Maven para proyecto OCP Java SE 17..." -ForegroundColor Green

# Función para crear pom.xml de capítulo
function Create-ChapterPom {
    param (
        [string]$chapterPath,
        [string]$chapterNumber,
        [string]$chapterName,
        [array]$modules
    )

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
    <name>OCP Chapter $chapterNumber - $chapterName</name>

    <modules>
"@

    foreach ($module in $modules) {
        $pomContent += "`n        <module>$module</module>"
    }

    $pomContent += @"

    </modules>

</project>
"@

    $pomPath = Join-Path $chapterPath "pom.xml"
    Set-Content -Path $pomPath -Value $pomContent -Encoding UTF8
    Write-Host "✅ Creado: $pomPath" -ForegroundColor Green
}

# Función para crear pom.xml de ejemplo individual  
function Create-ExamplePom {
    param (
        [string]$examplePath,
        [string]$exampleId,
        [string]$exampleName,
        [string]$mainClass = $null
    )

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
    <name>Example $exampleName</name>

    <build>
"@

    # Determinar estructura de directorios según el tipo de ejemplo
    if ($chapterNum -ge 19) {
        # Módulos Java 9+ - estructura src/ estándar
        $pomContent += @"

        <sourceDirectory>src</sourceDirectory>
"@
    } else {
        # Ejemplos tradicionales - archivos en raíz (default package)
        $pomContent += @"

        <sourceDirectory>.</sourceDirectory>
        <outputDirectory>.</outputDirectory>
"@
    }

    $pomContent += @"

        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <includes>
                        <include>**/*.java</include>
                    </includes>
                    <excludes>
                        <exclude>**/*.class</exclude>
                    </excludes>
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

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-clean-plugin</artifactId>
                <configuration>
                    <filesets>
                        <fileset>
                            <directory>.</directory>
                            <includes>
                                <include>*.class</include>
                            </includes>
                        </fileset>
                    </filesets>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
"@

    $pomPath = Join-Path $examplePath "pom.xml"
    Set-Content -Path $pomPath -Value $pomContent -Encoding UTF8
    Write-Host "✅ Creado: $pomPath" -ForegroundColor Green
}

# Función para detectar clase main en un directorio
function Find-MainClass {
    param ([string]$path)
    
    $javaFiles = Get-ChildItem -Path $path -Filter "*.java" -Recurse
    foreach ($file in $javaFiles) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "public\s+static\s+void\s+main\s*\(\s*String\s*\[\s*\]\s*\w+\s*\)") {
            return $file.BaseName
        }
    }
    return $null
}

# === PROCESO PRINCIPAL ===

$rootPath = Get-Location
Write-Host "📁 Directorio raíz: $rootPath" -ForegroundColor Cyan

# Obtener todos los directorios de capítulos
$chapterDirs = Get-ChildItem -Directory | Where-Object { $_.Name -match "^OCP_Ch\d+$" } | Sort-Object Name

foreach ($chapterDir in $chapterDirs) {
    Write-Host "`n📚 Procesando $($chapterDir.Name)..." -ForegroundColor Yellow
    
    # Extraer número de capítulo
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
        
        Create-ExamplePom -examplePath $exampleDir.FullName -exampleId $exampleId -exampleName $exampleDir.Name -mainClass $mainClass
    }
    
    # Crear pom.xml para el capítulo
    $chapterName = "Chapter $chapterNumber Examples"
    if ([int]$chapterNumber -ge 19) {
        $chapterName += " (Modules)"
    }
    
    Create-ChapterPom -chapterPath $chapterDir.FullName -chapterNumber $chapterNumberPadded -chapterName $chapterName -modules $modules
}

Write-Host "`n🎉 ¡Proceso completado!" -ForegroundColor Green
Write-Host "💡 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   • mvn clean compile          # Compilar todo"
Write-Host "   • mvn clean compile -Pbasic-examples    # Solo capítulos 1-10"
Write-Host "   • mvn clean compile -Pmodular-examples  # Solo capítulos 19-25"
Write-Host "   • cd OCP_Ch01/Example_1_5 && mvn exec:java   # Ejecutar ejemplo específico"
Write-Host "`n📖 Para más información, consulta el README que se va a crear.""