const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const postmanFile = './static/API FACTURADOR PRO 8.postman_collection.json';
const outputFile = './apifacturador/api-rest.yaml';

async function convert() {
  try {
    console.log('🔄 Converting Postman collection to OpenAPI...');
    
    // Read Postman collection
    const postmanData = JSON.parse(fs.readFileSync(postmanFile, 'utf8'));
    
    // Create OpenAPI structure
    const openapi = {
      openapi: '3.0.3',
      info: {
        title: postmanData.info.name || 'API FACTURADOR',
        description: 'API REST para el Sistema de Facturación Electrónica',
        version: '1.0.0',
        contact: {
          name: 'Soporte Facturador',
          email: 'soporte@pro8.pe'
        }
      },
      servers: [
        {
          url: 'https://cliente.tu-dominio.com',
          description: 'Servidor de Producción'
        },
        {
          url: 'https://empresa01.tudominio.pe',
          description: 'Servidor de Demostración'
        }
      ],
      paths: {},
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT'
          }
        },
        schemas: {}
      },
      security: [
        {
          bearerAuth: []
        }
      ]
    };
    
    // Parse Postman items recursively
    let operationCounter = {};
    
    function parseItems(items, basePath = '') {
      items.forEach(item => {
        if (item.item) {
          // It's a folder, recurse
          parseItems(item.item, item.name);
        } else if (item.request) {
          // It's a request
          const request = item.request;
          const method = request.method.toLowerCase();
          
          // Build path from URL
          let pathStr = '/api';
          if (request.url && request.url.path) {
            pathStr = '/' + request.url.path.join('/');
          }
          
          // Create unique operation ID from request name
          const operationId = item.name
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '');
          
          // If same path+method exists, append counter to make unique path
          const pathKey = `${pathStr}_${method}`;
          if (!operationCounter[pathKey]) {
            operationCounter[pathKey] = 0;
          }
          operationCounter[pathKey]++;
          
          // For duplicate path+method combos, create unique path with operation ID
          let uniquePath = pathStr;
          if (operationCounter[pathKey] > 1 || (openapi.paths[pathStr] && openapi.paths[pathStr][method])) {
            uniquePath = `${pathStr}/{${operationId}}`;
          }
          
          // Initialize path if doesn't exist
          if (!openapi.paths[uniquePath]) {
            openapi.paths[uniquePath] = {};
          }
          
          // Build operation
          const operation = {
            operationId: operationId,
            summary: item.name,
            description: item.description || item.name,
            tags: [basePath || 'General'],
            responses: {
              '200': {
                description: 'Successful response',
                content: {
                  'application/json': {
                    schema: {
                      type: 'object'
                    }
                  }
                }
              },
              '400': {
                description: 'Bad Request'
              },
              '401': {
                description: 'Unauthorized'
              },
              '500': {
                description: 'Internal Server Error'
              }
            }
          };
          
          // Add request body if exists
          if (request.body && request.body.raw) {
            try {
              const bodyExample = JSON.parse(request.body.raw);
              operation.requestBody = {
                required: true,
                content: {
                  'application/json': {
                    schema: {
                      type: 'object',
                      example: bodyExample
                    }
                  }
                }
              };
            } catch (e) {
              // Invalid JSON, skip
            }
          }
          
          openapi.paths[uniquePath][method] = operation;
        }
      });
    }
    
    // Parse all items
    if (postmanData.item && postmanData.item.length > 0) {
      postmanData.item.forEach(topLevel => {
        if (topLevel.item) {
          parseItems(topLevel.item, topLevel.name);
        }
      });
    }
    
    // Ensure output directory exists
    const outputDir = path.dirname(outputFile);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // Write YAML file
    const yamlStr = yaml.dump(openapi, { lineWidth: -1, noRefs: true });
    fs.writeFileSync(outputFile, yamlStr, 'utf8');
    
    console.log('✅ Conversion successful!');
    console.log(`📄 OpenAPI spec generated at: ${outputFile}`);
    
    const stats = fs.statSync(outputFile);
    console.log(`📊 File size: ${(stats.size / 1024).toFixed(2)} KB`);
    console.log(`🔗 Paths generated: ${Object.keys(openapi.paths).length}`);
    
  } catch (error) {
    console.error('❌ Conversion failed:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  }
}

convert();
