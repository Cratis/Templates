global using System.Reactive.Subjects;
#if cratisMongoDb
global using Cratis.Arc.MongoDB;
global using MongoDB.Driver;
#else
global using Cratis.Arc.EntityFrameworkCore;
global using Microsoft.EntityFrameworkCore;
#endif
