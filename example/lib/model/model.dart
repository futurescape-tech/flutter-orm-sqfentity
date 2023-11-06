import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

import '../tools/helper.dart';
import 'view.list.dart';

part 'model.g.dart';
part 'model.g.view.dart';

// STEP 1: define your tables as shown in the example Classes below.

// Define the 'tableCategory' constant as SqfEntityTable for the category table
const tableCategory = SqfEntityTable(
    tableName: 'category',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: false,
    // when useSoftDeleting is true, creates a field named 'isDeleted' on the table, and set to '1' this field when item deleted (does not hard delete)
    modelName:
        null, // SqfEntity will set it to TableName automatically when the modelName (class name) is null
    // declare fields
    fields: [
      SqfEntityField('name', DbType.text, isNotNull: true),
      SqfEntityField('isActive', DbType.bool, defaultValue: true),
    ],
    formListSubTitleField: '');

// Define the 'tableProduct' constant as SqfEntityTable for the product table
const tableProduct = SqfEntityTable(
    tableName: 'product',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField(
        'name',
        DbType.text,
        isNotNull: true,
      ),
      SqfEntityField('description', DbType.text),
      SqfEntityField('price', DbType.real, defaultValue: 0),
      SqfEntityField('isActive', DbType.bool, defaultValue: true),

      /// Relationship column for CategoryId of Product
      SqfEntityFieldRelationship(
          parentTable: tableCategory,
          deleteRule: DeleteRule.CASCADE,
          defaultValue: 1,
          formDropDownTextField:
              'name' // displayText of dropdownList for category. 'name' => a text field from the category table
          ),
      SqfEntityField('rownum', DbType.integer,
          sequencedBy:
              seqIdentity /*Example of linking a column to a sequence */),
      SqfEntityField('imageUrl', DbType.text),
      SqfEntityField('datetime', DbType.datetime,
          isNotNull: true,
          defaultValue: 'DateTime.now()',
          minValue: '2019-01-01',
          maxValue: 'DateTime.now().add(Duration(days: 30))'),
      SqfEntityField('date', DbType.date,
          minValue: '2015-01-01',
          maxValue: 'DateTime.now().add(Duration(days: 365))')
    ]);

const tableParkedBills = SqfEntityTable(
  tableName: 'parkedBills',
  modelName: 'ParkedBill',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityField('billId', DbType.text, isUnique: true),
    SqfEntityField('name', DbType.text, isUnique: true),
    SqfEntityField('subtotal', DbType.real, defaultValue: 0),
    SqfEntityField('tax', DbType.real, defaultValue: 0),
    SqfEntityField('discount', DbType.real, defaultValue: 0),
    SqfEntityField('netAmount', DbType.real, defaultValue: 0),
  ]
);

const tableParkedBillItems = SqfEntityTable(
  tableName: 'parkedBillItems',
  modelName: 'ParkedBillItem',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityFieldRelationship(
      parentTable: tableParkedBills,
      deleteRule: DeleteRule.CASCADE,
      relationType: RelationType.ONE_TO_MANY,
      fieldName: 'pLocalBillId'
    ),
    SqfEntityField('itemId', DbType.text, isUnique: true),
    SqfEntityField('pBillId', DbType.text),
    SqfEntityField('name', DbType.text, isNotNull: true),
    SqfEntityField('image', DbType.text),
    SqfEntityField('quantity', DbType.numeric),
    SqfEntityField('subtotal', DbType.real, defaultValue: 0),
    SqfEntityField('tax', DbType.real, defaultValue: 0),
    SqfEntityField('discount', DbType.real, defaultValue: 0),
    SqfEntityField('netAmount', DbType.real, defaultValue: 0),
  ]
);

const tableParkedBillItemTaxes = SqfEntityTable(
  tableName: 'parkedBillItemTaxes',
  modelName: 'ParkedBillItemTax',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityFieldRelationship(
      parentTable: tableParkedBillItems,
      deleteRule: DeleteRule.CASCADE,
      relationType: RelationType.ONE_TO_MANY,
      fieldName: 'pLocalItemId'
    ),
    SqfEntityField('taxId', DbType.text, isUnique: true),
    SqfEntityField('pItemId', DbType.text),
    SqfEntityField('name', DbType.text),
    SqfEntityField('taxMethod', DbType.text),
    SqfEntityField('type', DbType.text),
    SqfEntityField('rate', DbType.real),
    SqfEntityField('tax', DbType.real)
  ]
);

const tableProductCategory = SqfEntityTable(
    tableName: 'productCategories',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    modelName: 'ProductCategory',
    fields: [
      SqfEntityField('categoryId', DbType.text, isUnique: true),
      SqfEntityField('name', DbType.text, isNotNull: true),
      SqfEntityField('isActive', DbType.bool, defaultValue: true),
    ]);

const tableProductt = SqfEntityTable(
    tableName: 'productt',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    modelName: 'Productt',
    fields: [
      SqfEntityField(
        'name',
        DbType.text,
        isNotNull: true,
      ),
      SqfEntityField(
        'productId',
        DbType.text,
        isUnique: true
      ),
      SqfEntityField('description', DbType.text),
      SqfEntityField('price', DbType.real, defaultValue: 0),
      SqfEntityField('isActive', DbType.bool, defaultValue: true),
      SqfEntityFieldRelationship(
          parentTable: tableProductCategory,
          deleteRule: DeleteRule.CASCADE,
          relationType: RelationType.MANY_TO_MANY,
          manyToManyTableName: 'productCategoryLink',
          isPrimaryKeyField: false
      ),
      SqfEntityField('imageUrl', DbType.text)
    ]);

const tableProductCategoryLink = SqfEntityTable(
    tableName: 'productCategoryLink',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    modelName: 'ProductCategoryLink',
    fields: [
      SqfEntityFieldRelationship(
          parentTable: tableProductCategory,
          fieldName: 'pLocalCategoryId',
          deleteRule: DeleteRule.CASCADE,
          relationType: RelationType.ONE_TO_MANY,
          isPrimaryKeyField: false
      ),
      SqfEntityFieldRelationship(
          parentTable: tableProductt,
          fieldName: 'pLocalProductId',
          deleteRule: DeleteRule.CASCADE,
          relationType: RelationType.ONE_TO_MANY,
          isPrimaryKeyField: false
      ),
    ]);

// Define the 'Todo' constant as SqfEntityTable.
const tableTodo = SqfEntityTable(
    tableName: 'todos',
    primaryKeyName: 'id',
    useSoftDeleting:
        false, // when useSoftDeleting is true, creates a field named 'isDeleted' on the table, and set to '1' this field when item deleted (does not hard delete)
    primaryKeyType: PrimaryKeyType.integer_unique,
    defaultJsonUrl:
        'https://jsonplaceholder.typicode.com/todos', // optional: to synchronize your table with json data from webUrl

    // declare fields
    fields: [
      SqfEntityField('userId', DbType.integer, isIndex: true),
      SqfEntityField('title', DbType.text),
      SqfEntityField('completed', DbType.bool, defaultValue: false),
    ]);

// Define the 'identity' constant as SqfEntitySequence.
const seqIdentity = SqfEntitySequence(
  sequenceName: 'identity',
  //maxValue:  10000, /* optional. default is max int (9.223.372.036.854.775.807) */
  //modelName: 'SQEidentity',
  /* optional. SqfEntity will set it to sequenceName automatically when the modelName is null*/
  //cycle : false,    /* optional. default is false; */
  //minValue = 0;     /* optional. default is 0 */
  //incrementBy = 1;  /* optional. default is 1 */
  // startWith = 0;   /* optional. default is 0 */
);

// STEP 2: Create your Database Model constant instanced from SqfEntityModel
// Note: SqfEntity provides support for the use of multiple databases.
// So you can create many Database Models and use them in the application.
@SqfEntityBuilder(myDbModel)
const myDbModel = SqfEntityModel(
    modelName: 'MyDbModel',
    databaseName: 'sampleORM_v2.1.2+39.db',
    password:
        null, // You can set a password if you want to use crypted database (For more information: https://github.com/sqlcipher/sqlcipher)
    // put defined tables into the tables list.
    databaseTables: [tableProduct, tableCategory, tableTodo, tableParkedBills, tableParkedBillItems, tableParkedBillItemTaxes, tableProductCategoryLink, tableProductCategory, tableProductt],
    // You can define tables to generate add/edit view forms if you want to use Form Generator property
    formTables: [tableProduct, tableCategory, tableTodo],
    // put defined sequences into the sequences list.
    sequences: [seqIdentity],
    dbVersion: 2,
    // This value is optional. When bundledDatabasePath is empty then
    // EntityBase creats a new database when initializing the database
    bundledDatabasePath: null, //         'assets/sample.db'
    // This value is optional. When databasePath is null then
    // EntityBase uses the default path from sqflite.getDatabasesPath()
    // If you want to set a physically path just set a directory like: '/Volumes/Repo/MyProject/db',
    databasePath: null,
    defaultColumns: [
      SqfEntityField('dateCreated', DbType.datetime,
          defaultValue: 'DateTime.now()'),
    ]);

/* STEP 3: That's All.. 
--> Go Terminal Window and run command below
    flutter pub run build_runner build --delete-conflicting-outputs
  Note: After running the command Please check lib/model/model.g.dart and lib/model/model.g.view.dart (If formTables parameter is defined in the model)
  Enjoy.. Huseyin TOKPINAR
*/
